export CLUSTER_NAME=cluster-1234

cluster:
	kind create cluster --config kind.yaml --name $(CLUSTER_NAME)
	kubectl config use-context kind-$(CLUSTER_NAME)

	@echo "Listing the nodes in the cluster"
	kubectl get nodes

delete-cluster:
	kind delete cluster --name $(CLUSTER_NAME)

	@echo "Cluster deleted"

list-images:
	docker exec -it $(CLUSTER_NAME)-control-plane crictl images

export PORT=5005

dev:
	uv run fastapi dev api.py --port $(PORT)

build:
	docker build -t simple-api:v1.0.0 .

run:
	docker run -it -p $(PORT):5000 simple-api:v1.0.0

push:
	kind load docker-image simple-api:v1.0.0 --name $(CLUSTER_NAME)

deploy: build push
	kubectl apply -f deployment.yaml
	kubectl apply -f service.yaml
	kubectl wait --for=condition=ready pod -l app=simple-api --timeout=60s
	kubectl port-forward svc/simple-api $(PORT):5000

test:
	curl http://localhost:$(PORT)/health -w "\n"