# 🐳 Move Docker Images from One PC to Another  
### 💾 Save on your data bundle by using LAN transfer

Transfer your Docker images between two machines on the same network—fast and offline.

---

## ✅ Step 1: Make the script executable on the **source PC**

Replace `export-all-docker-images.sh` with your actual script file name.

```bash
chmod +x export-all-docker-images.sh


## ✅ Step 2: Run the command below on the recepient PC:
`wget http://10.10.2.50:8000/all-docker-images.tar`
`docker load -i all-docker-images.tar`

