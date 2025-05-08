### Start region: Setting global variables
$dev_dir = $env:userprofile + "\dev"

### End region

### Start region: Starting chrome from powershell terminal
function chrome { 
    param(
        [Parameter(Position=0, ValueFromPipeline)]
        [string] $url
    )
    if ($url){
        Start-process -FilePath C:\'Program Files'\Google\Chrome\Application\chrome.exe $url;
    } elseif (Test-Path -Path ".git"){
        $git_url = ((git ls-remote --get-url) -replace ':', '/') -replace 'git@', 'https://';
        Start-process -FilePath C:\'Program Files'\Google\Chrome\Application\chrome.exe $git_url; 
    } else {
        Start-process -FilePath C:\'Program Files'\Google\Chrome\Application\chrome.exe google.com;
    }  
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

### Start region: Dev directory location in terminal
function dev-dir {
    
}