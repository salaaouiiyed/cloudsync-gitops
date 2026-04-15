# Guide de Déploiement Kubernetes pour CloudSync

Ce dossier contient les manifestes Kubernetes nécessaires pour déployer l'application **CloudSync** sur votre cluster **Azure Kubernetes Service (AKS)**, en utilisant l'**Application Gateway Ingress Controller (AGIC)**.

## Fichiers inclus

| Fichier | Rôle |
|---------|------|
| `backend-deployment.yaml` | Déploiement de l'API (Backend) avec 2 réplicas. |
| `backend-service.yaml` | Service interne pour exposer le Backend. |
| `frontend-deployment.yaml` | Déploiement de l'interface utilisateur (Frontend). |
| `frontend-service.yaml` | Service interne pour exposer le Frontend. |
| `keycloak-deployment.yaml` | Déploiement de Keycloak pour l'authentification. |
| `keycloak-service.yaml` | Service interne pour exposer Keycloak. |
| `keycloak-realm-configmap.yaml` | Configuration du royaume (realm) pour Keycloak. |
| `ingress.yaml` | Configuration de l'Ingress pour l'Application Gateway. |

## Instructions de déploiement

1. **Pousser les images vers ACR** :
   Assurez-vous que vos images Docker sont construites et poussées vers votre registre Azure Container Registry (`acrcloudsync2026.azurecr.io`).

2. **Appliquer les configurations** :
   Exécutez les commandes suivantes dans l'ordre :
   ```bash
   kubectl apply -f keycloak-realm-configmap.yaml
   kubectl apply -f keycloak-service.yaml
   kubectl apply -f keycloak-deployment.yaml
   kubectl apply -f backend-service.yaml
   kubectl apply -f backend-deployment.yaml
   kubectl apply -f frontend-service.yaml
   kubectl apply -f frontend-deployment.yaml
   kubectl apply -f ingress.yaml
   ```

3. **Configuration SQL** :
   Le backend est configuré pour se connecter à **Azure SQL Database**. Assurez-vous que le mot de passe est correctement défini dans `backend-deployment.yaml` ou utilisez un secret Kubernetes.

4. **Accès externe** :
   L'application sera accessible via l'adresse IP publique de l'**Application Gateway** configurée dans votre infrastructure Terraform.
