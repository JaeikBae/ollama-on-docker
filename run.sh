sudo docker build -t ollama .
sudo docker run --rm -d \
	-v ./data/root:/root \
	-v ./data/db:/ws/open-webui/backend/data \
	--name ollama_serve \
	--gpus=all \
	--network host \
	ollama
