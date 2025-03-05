# HOW TO DEPLOY:

1. Git Clone application from github

   ```
   git clone https://github.com/jrione/kubernetes-lab && cd kubernetes-lab
   ```
2. Create folder /mnt/data, copy index.html and set with rwx permission

   ```
   mkdir /mnt/data
   cp $(pwd)/app/index.html /mnt/data
   chmod -R 777 /mnt/data
   chown -R nobody:nogroup /mnt/data
   ```
3. Create namespace named `example`

   ```
   kubectl create namespace example
   ```
4. Create persistent volume for store data

   ```
   kubectl apply -f pv.yaml
   ```
5. Apply configmap & secret for apps

   ```
   kubectl apply -f configmap.yaml -f secret.yaml
   ```
6. Deploy application & expose it

   ```
   kubectl apply -f deployment.yaml -f hpa.yaml -f service.yaml
   ```
7. Check service of application, and access it

   ```
   kubectl get service -n example
   ```
8. And then, access your app. http://<YOUR_IP>:32000
