package main

import (
	"errors"
	"fmt"
	"os"
)

const (
	VSCODE_PATH     = "./.vscode"
	TASKS_FILE_PATH = "./.vscode/tasks.json"
	POM_PATH        = "./pom.xml"
)

var (
	JAVA_COMMANDS = [6]string{"mvn clean verify",
		"mvn spring-boot:run",
		"java -jar -agentlib:jdwp=transport=dt_socket,server=y,suspend=y,address=*:5005 target/*.jar",
		"mvn clean package -DskipTests",
		"mvn clean install",
		"mvn spotless:apply"}
)

func main() {

}

func create_vscode_directory() {
	if _, err := os.Stat(VSCODE_PATH); err != nil {
		if err = os.Mkdir(VSCODE_PATH, os.ModeDir); err != nil {
			errors.New("Check the permissions for the Golang script: " + err.Error())
		}
	}
	fmt.Println(".vscode directory created")
}

func is_root_project() {
	if _, err := os.Stat(POM_PATH); err != nil {
		errors.New("Not on project root: " + err.Error())
	}
	fmt.Println("On root Project")
}
