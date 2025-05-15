### Start region: Setting global variables
$dev_dir = $env:userprofile + "\dev"
### End region

### Start region: Installing essential packages
function install-essentials() {
    if (!(get-command fzf)){
        winget install fzf; 
        echo "fzf installed";
    }
    if (!(get-command vim)) {
        New-Item -Path "$dev_dir\trial" -itemtype "directory" && Invoke-WebRequest -Uri "https://github.com/vim/vim-win32-installer/releases/download/v9.1.1374/gvim_9.1.1374_x64.exe" -OutFile "$dev_dir\trial\installer.exe";
        Start-process "$dev_dir\trial\installer.exe" -Confirm;
    }
    if (!(get-command jq)){
        winget install jqlang.jq;
    }

    # For javascript and typescript - fnm, node, npm, typescript 
    if (!(get-command fnm)){
        winget install Schniz.fnm;
        fnm install --lts; # installs the lts versions of node and npm
        npm install typescript -g;
        Write-Host "Latest versions of node, npm and typescript downloaded";
    }
}

install-essentials;

###

### Start region: Starting chrome from powershell terminal
function chrome { 
    param(
        [Parameter(Position=0, ValueFromPipeline)]
        [string] $url
    )
    if ($url){
        Start-process -FilePath C:\'Program Files'\Google\Chrome\Application\chrome.exe "$url";
    } elseif (Test-Path -Path ".git"){
        $git_url = ((git ls-remote --get-url) -replace ':', '/') -replace 'git@', 'https://';
        Start-process -FilePath C:\'Program Files'\Google\Chrome\Application\chrome.exe $git_url; 
    } else {
        Start-process -FilePath C:\'Program Files'\Google\Chrome\Application\chrome.exe google.com;
    }  
}
### End region

### Start region: Starting bookmark web access for Default profile
function bookmark {
    $file = "$ENV:USERPROFILE\AppData\Local\Google\Chrome\User Data\Default\Bookmarks";
    if (!(Test-Path -Path "$file")) {
        $file = Read-Host "Enter the bookmarks file path:";
    }
    tsc bookmarks.ts;
    $selected = node bookmarks.js "$file" | fzf;
    $url = $selected.Substring($selected.LastIndexOf("~") + 1);
    Start-process -FilePath C:\'Program Files'\Google\Chrome\Application\chrome.exe $url;
}
### End region

### Start region: Cloning github repositories in appropriate location
function dev-clone {
    param(
        [Parameter(Position=0, Mandatory, ValueFromPipeline)]
        [string] $url
    )
    if($url -match "https://.*"){
        _process_url($url);       
    } elseif ($url -match "git@.*"){
        $dir = $url;
        $dir = $dir.Replace(":", "/").Replace("git@", "https://");
        _process_url($dir)
    }
}

function _process_url([string]$url){
    $dir = $url;
    $dir = $dir.Replace("https://", "");
    $dir = $dir.Replace(".git", "");
    $dir = $dir.Replace("/", "\");
    $last_index = $dir.LastIndexOf("\");
    $repo = $dir;
    $dir = $dir.Substring(0,$last_index);
    $dir = $dev_dir + "\" + $dir;
    if (!(Test-Path -Path "$dir")){
        New-Item -ItemType "directory" $dir;
    } else {
        $repo = $repo.Substring($last_index + 1).Replace(".git", "");
        $repo = $dir + "\" + $repo;
        if (Test-Path -Path $repo){
            Write-Host "The repo already exists: $repo"
        } else {
            Push-Location .;
            Set-Location $dir;
            git clone $url;
            Pop-Location;
            Write-Host "The repo is cloned: $repo";
        }
    }
}
### End region

### Start region: private function for fetching dev directories
function _selected () {
    $_select = (Get-Childitem -Path $dev_dir -Directory -Recurse -Depth 4 | Where-Object { Test-Path (Join-Path $_.FullName '.git') } | ForEach-Object {$_.FullName} | fzf);
    echo "$_select";
}
### End region: 

### Start region: Dev directory location in terminal
function dev-dir {
    $selected = (_selected);
    echo "$selected";
    Set-Location $selected;
}

### End region

### Start region: Open Code in dev location
function dev-code {
    $selected = (_selected);
    echo "$selected";
    code $selected;
}
### End region

### Start region: git commands for no edit commit msg and amending a commit
function nocommit() {
    if (!(Test-Path -PathType Container -Path ".git")){
        Write-Host "Not a git project";
        return;
    }
    git commit --amend --no-edit && git push --force;
} 

function gitMaster() {
    git checkout $(git branch --remotes | Where-Object { $_ -match "HEAD"} | ForEach-Object {$_ -replace ".*-> ", ""});
}

### End region

### Start region: Maven commands for Java Projects
function mvnTree() {
    if (!(Test-Path -Path "pom.xml")){
        Write-Host "Not a maven project";
        return;
    }
    mvn dependency:tree | code -
}

function mvnNew() {
    $groupId = Read-Host "Enter the groupId: ";
    $artifactId = Read-Host "Enter the artifactId: ";
    $version = Read-Host "Enter version number: ";
    if (Test-Path -Path $artifactId) {
        Write-Host "Project already exists with the same artifact Id";
        return;
    }
    Write-Host "Creating Maven Project...";
    mvn archetype:generate -DgroupId="$groupId" -DartifactId="$artifactId" -Dversion="$version" -archetypeArtifactId=maven-archetype-quickstart -DinteractiveMode=false -q
    New-Item -ItemType "directory" "$artifactId\src\main\resources";
    New-Item -ItemType "directory" "$artifactId\src\test\resources";
}

### End region

### Start region: Multiple Java versions in Windows
$java_dir = "C:\Program Files\Java\"

function _choose-java () {
    $_chosen_java = $(Get-Childitem -Directory -Path "$java_dir" | ForEach-Object {$_.Name} | fzf);
    Write-Output $_chosen_java;
}

function use-java () {
    $chosen_java = $(_choose-java);
    $Env:Path = $Env:Path -replace "jdk-\d{2}", $chosen_java;
    $Env:JAVA_HOME = "$java_dir$chosen_java";
    Write-Output "Using $chosen_java in the current shell";
}

### End region