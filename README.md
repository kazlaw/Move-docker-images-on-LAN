# Move-docker-images-on-LAN
Move docker images from one PC to Another and save on your data bundle

*Make it executable on source PC - example : `10.10.2.50`
`chmod +x export-all-docker-images.sh`

*Run it on source PC:*
`./export-all-docker-images.sh`

Run the command below on the recepient PC:
`wget http://10.10.2.50:8000/all-docker-images.tar`
`docker load -i all-docker-images.tar`

