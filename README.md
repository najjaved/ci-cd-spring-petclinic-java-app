# CI-CD for a Standalone Java App
Deploy the [Spring PetClinic Application](https://github.com/spring-projects/spring-petclinic) on Amazon Cloud using Github Actions Workflow.

## Run Petclinic locally

Spring Petclinic is a [Spring Boot](https://spring.io/guides/gs/spring-boot) application built using [Maven](https://spring.io/guides/gs/maven/) or [Gradle](https://spring.io/guides/gs/gradle/). You can build a jar file and run it from the command line (it should work just as well with Java 17 or newer):

Create fork of the repository: https://github.com/spring-projects/spring-petclinic.git
```bash
git clone <your-repository>
cd spring-petclinic
chmod +x mvnw
./mvnw package (to build, test and generate artifacts)
java -jar target/*.jar (starts the application)
```
You can then access the Petclinic at <http://localhost:8080/>
</br>

```bash
cd target
ls
.nvmw test (for running unit tests)
```
Run Sonarqube analysis locally on java code and check results on Sonarqube dashboard ```http://<IP-address>:9000```

```bash
mvn clean verify sonar:sonar \
  -Dsonar.projectKey=<sonarqube-project-name> \
  -Dsonar.projectName='<sonarqube-project-name>' \
  -Dsonar.host.url=<sonarqube-host-url> \
  -Dsonar.token=<your-sonarqube-project-token>
```
---
Now proceed with CI-CD using Githb Actions.

## Steps:
- Running the Petclinic App locally to ensure it works as expected (optional)
- Setting up a Continuous Integration (CI) pipeline using GitHub Actions to build and test the code using Maven
- Integrating SonarQube for code quality analysis
- Packaging and storing artifacts (JAR files)
- Deploying the JAR file to an AWS EC2 instance
</br>

### Continuous Integration
- Check out the code
- Build the code using Maven (wrapper included)
- Run tests
- Analyze code quality using SonarQube
- Archive the JAR file as an artifact for later use

### Continuous Deployment
The second part of the pipeline (the deploy job) runs after the build job if it’s successful
- Download the JAR artifact from the previous build
- Securely copy (scp) the new JAR to /home/ubuntu on the EC2 instance
- Ensure Java is installed (```sudo apt update && sudo apt install -y openjdk-17-jre```)
- SSH into the EC2 machine, killing any process that might already be running on port 8080
- Start Spring PetClinic in the background using ```nohup```

**Important Notes**: Make sure your EC2 instance’s security group allows inbound traffic on port 8080 so that you can reach the PetClinic app in a browser. </br> 
In your GitHub repository settings, under “Secrets and variables” → “Actions”, add: </br>
SONAR_HOST_URL, SONAR_TOKEN, EC2_HOST, EC2_PRIVATE_KEY

### Verification
After the pipeline finishes, visit:

``` 
http://<EC2_PUBLIC_IP_OR_DNS>:8080
```
You should see the Spring PetClinic landing page. Additionally, log into your SonarQube server ```http://<sonarqube-EC2-instance-public-ip-or-host>:9000``` and verify that the Spring-PetClinic analysis is present.

### Troubleshooting
SSH into your EC2 instance manually: ```ssh -i <your-private-key> <user>@<IP adress>```

1. Verify Java is installed and JAR file exists: ```java -version``` and ```ls -l /home/ubuntu/app.jar```
2. Run the nohup java -jar command manually: ```nohup java -jar /home/ubuntu/spring-petclinic-*.jar > app.log 2>&1 &```
3. Verify Application running: ```curl localhost:8080``` or ```ps aux | grep java```
4. If not, check the app.log file for any error messages: ```tail app.log```