# tf-iam-security-practices 🛡️

A small Terraform project that shows **good IAM and security habits** in AWS—things like using roles, scoped policies, and reusable modules. It also demonstrates **policy-as-code** with Checkov to enforce rules beyond Terraform itself.

---

## What you’ll need ✅
- An **AWS account** (preferably a sandbox/non-prod one)
- **Terraform** installed (v1.5+ recommended)
- An **AWS profile** set up locally (`aws configure`) with permissions to create IAM resources
- **Python 3** installed (for Checkov custom policies)
- **Checkov** installed:  
  ```bash
  pip install checkov
  ```

---

## Quick start 🚀
```bash
# 1) Clone
git clone https://github.com/montalvolll/tf-iam-security-practices.git
cd tf-iam-security-practices

# 2) (Optional) Create a tfvars file to override defaults
cp example.tfvars terraform.tfvars   # if provided

# 3) Initialize & review changes
terraform init
terraform plan -out plan.tfplan

# 4) Apply
terraform apply plan.tfplan
```

> Tip: If you use multiple AWS accounts or profiles, run with  
> `AWS_PROFILE=your-profile terraform plan` (and `apply`).

---

## What this sets up 🔍
- **IAM roles & policies** following least-privilege ideas
- **Reusable Terraform modules** for common IAM patterns
- **Custom policy checks** with Checkov to enforce rules like:
  - Restricting allowed instance types
  - Restricting CIDR blocks in security groups

---

## Custom policies with Checkov 🧑‍💻
This repo includes a `custom_policies/` folder with **Python-based Checkov policies**.

### Run a scan
```bash
checkov -d . --external-checks-dir custom_policies
```

This will run Checkov against the Terraform code and include custom rules.  
For example, you can enforce:
- Only a specific **instance type** (e.g., `t3.micro`)  
- Only an approved **CIDR block** for network resources  

If Terraform code violates these rules, Checkov will **fail the scan** and highlight the issue.

---

## Configure it (simple version) 🔧
1. Open `variables.tf` to see available inputs.
2. Either:
   - Put your values in `terraform.tfvars`, **or**
   - Pass `-var key=value` on the command line.
3. Run `terraform plan` again to confirm changes.

Common things to set:
- Naming prefixes
- Roles/policies to create
- Allowed actions/resources
- Instance types & CIDRs (that must pass Checkov rules)

---

## Clean up 🧹
When done testing, tear everything down:
```bash
terraform destroy
```

---

## Project structure 📁
```
modules/           # Reusable IAM building blocks
custom_policies/   # Python-based Checkov custom policies
main.tf            # Entry point: what gets created
variables.tf       # Inputs
providers.tf       # AWS provider config
versions.tf        # Required versions
outputs.tf         # Handy outputs after apply
```

---

## Tips & gotchas 💡
- Prefer **roles over long-lived users/keys**  
- Enforce **least privilege** everywhere  
- Use **Checkov** to keep your code compliant  
- Clean up after testing (destroy resources)

---

## FAQ ❔
**Q: Can I run this in prod?**  
A: Treat this as a **learning/baseline** repo. Review policies carefully before production use.

**Q: How do I enforce my own rules with Checkov?**  
A: Add Python files in `custom_policies/` with your own logic. Checkov will automatically pick them up with `--external-checks-dir`.

**Q: Why both Terraform & Checkov?**  
A: Terraform provisions infra. Checkov prevents **bad practices** from slipping through.

---

## References 📚
- [AWS IAM security best practices](https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html)
- [Terraform AWS provider docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Checkov custom policies guide](https://www.checkov.io/3.Custom%20Policies/Python%20Custom%20Policies.html)
