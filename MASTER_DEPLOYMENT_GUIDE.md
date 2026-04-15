# الدليل الشامل لنشر مشروع CloudSync باستخدام Argo CD و Azure AGIC

هذا الدليل مصمم لضمان عمل مشروعك بنسبة 100% على حساب Azure Student مع ميزانية 100 دولار.

---

## المرحلة 1: التحضير (GitHub & ACR)
1.  **رفع الكود:** قم برفع جميع ملفات الـ YAML الموجودة في هذا المجلد إلى مستودع (Repository) جديد على GitHub (مثلاً باسم `cloudsync-k8s`).
2.  **الصور (Images):** تأكد من أنك قمت بعمل Build و Push لصور الـ Frontend والـ Backend إلى الـ Azure Container Registry (ACR) الخاص بك:
    *   `acrcloudsync2026.azurecr.io/cloudsync-frontend:latest`
    *   `acrcloudsync2026.azurecr.io/cloudsync-backend:latest`

---

## المرحلة 2: إعداد Argo CD (على الـ Jumpbox)
1.  **تسجيل الدخول:**
    ```bash
    # الحصول على كلمة المرور
    kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
    ```
2.  **إضافة المستودع:** في واجهة Argo CD، اذهب إلى **Settings > Repositories** وأضف رابط مستودع GitHub الخاص بك.
3.  **إنشاء التطبيق (Application):**
    *   **Application Name:** `cloudsync`
    *   **Project:** `default`
    *   **Sync Policy:** `Automatic` (مع تفعيل Prune و SelfHeal).
    *   **Repository URL:** رابط مستودعك.
    *   **Path:** `.` (أو المجلد الذي وضعت فيه الملفات).
    *   **Cluster URL:** `https://kubernetes.default.svc`
    *   **Namespace:** `default`

---

## المرحلة 3: تفعيل الوصول الخارجي (AGIC)
بمجرد الضغط على **Sync** في Argo CD، سيحدث التالي:
1.  سيقوم Argo CD بإنشاء الـ Deployments والـ Services والـ Ingress.
2.  سيقوم **AGIC** (الموجود في AKS) بتحديث الـ **Application Gateway** تلقائياً.
3.  **كيف تجد الرابط؟** اذهب إلى بوابة Azure > Application Gateway > ابحث عن الـ **Frontend Public IP**. هذا هو الرابط الذي ستستخدمه للوصول لتطبيقك.

---

## المرحلة 4: إعدادات Keycloak النهائية (مهم جداً)
بعد أن يعمل التطبيق وتعرف الـ IP العام الخاص بك:
1.  ادخل إلى Keycloak عبر الرابط: `http://<YOUR_PUBLIC_IP>/auth`.
2.  ادخل بـ `admin` / `admin`.
3.  اذهب إلى **Clients > cloudsync-app**.
4.  قم بتحديث **Valid Redirect URIs** و **Web Origins** لتشمل الرابط الجديد: `http://<YOUR_PUBLIC_IP>/*`.

---

## حل المشاكل الشائعة (Troubleshooting):
*   **Pending IP:** إذا ظهرت لك هذه المشكلة، تأكد أنك لا تستخدم `type: LoadBalancer` في أي Service. استخدم دائماً الـ Ingress كما هو موضح في الملفات.
*   **ImagePullBackOff:** تأكد من أن الـ AKS لديه صلاحية الوصول للـ ACR (لقد أعددنا هذا في Terraform).
*   **Database Connection:** تأكد من أن كلمة المرور في `sql-secret.yaml` صحيحة وتطابق ما وضعته في Terraform.

---
**بالتوفيق في مناقشة الـ PFE!**
