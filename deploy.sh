#!/bin/bash

# Script de déploiement automatisé pour CloudSync sur AKS
# Assurez-vous d'être connecté à votre cluster AKS via 'az aks get-credentials'

echo "--- Démarrage du déploiement CloudSync ---"

# 1. Création des secrets et configurations de base
echo "[1/4] Création des secrets et ConfigMaps..."
kubectl apply -f sql-secret.yaml
kubectl apply -f keycloak-realm-configmap.yaml

# 2. Déploiement de l'authentification (Keycloak)
echo "[2/4] Déploiement de Keycloak..."
kubectl apply -f keycloak-service.yaml
kubectl apply -f keycloak-deployment.yaml

# Attente que Keycloak soit prêt (optionnel mais recommandé)
echo "Attente du démarrage de Keycloak..."
kubectl wait --for=condition=available --timeout=120s deployment/keycloak-deployment

# 3. Déploiement des applications (Backend & Frontend)
echo "[3/4] Déploiement du Backend et du Frontend..."
kubectl apply -f backend-service.yaml
kubectl apply -f backend-deployment.yaml
kubectl apply -f frontend-service.yaml
kubectl apply -f frontend-deployment.yaml

# 4. Configuration de l'accès externe (Ingress AGIC)
echo "[4/4] Configuration de l'Ingress (Application Gateway)..."
kubectl apply -f ingress.yaml

echo "--- Déploiement terminé ! ---"
echo "Vérifiez l'état des pods avec : kubectl get pods"
echo "Vérifiez l'adresse IP de l'Ingress avec : kubectl get ingress"
