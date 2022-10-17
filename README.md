## Code Structure
1. App folder - > Contains function and simple powershell server code
2. Test folder - > Contains unit test cases defined for function created.
3. Docker File -> To create docker image
4. App folder contains sample app.properties which we will use for creating config map

## Local Server 
Can be run **pwsh app/server.ps1** -> Server will be running on port 8080

## Test Cases 
Can be run **Invoke-Pester -Show Failed, Summary** from the home directory of app. You need to install module **Invoke-Pester** before running test cases using **Find-Module pester -Repository psgallery | Install-Module**

## Build Docker
This will load image in minikube cluster and will be available while creating pod
minikube image build -t dtest/rainfall .

## Config Map 
kubectl apply -f k8s-create-config.yaml

## Pod Run 
kubectl apply -f k8s-create-pod.yaml

## K8s Port forward
kubectl port-forward rainfall-pod 8080:8080

## K8s log
kubectl logs --follow rainfall-pod





