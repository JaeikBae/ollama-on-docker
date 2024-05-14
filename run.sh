sudo docker run --rm \
	-v ./data/root:/root \
	-v ./data/db:/ws/open-webui/backend/data \
	--name ollama_serve \
	--gpus=all \
	--network host \
	ollama
