# GitHub Actions 练习仓库

中文入门、运行机制、费用和可复制示例见 [readme-github-actions.md](readme-github-actions.md)。

工作流文件：

- [Hello](.github/workflows/workflow-playground-hello.yaml)：打印执行环境并检查入门文档。
- [Wait](.github/workflows/workflow-playground-wait.yaml)：等待 5 秒后继续执行下一步。

将仓库发布到 GitHub 后，打开 **Actions**，选择 **GitHub Actions Playground - Hello** 或 **GitHub Actions Playground - Wait**，再点击 **Run workflow**，即可运行示例。工作流需先出现在默认分支，且仓库已启用 Actions。

完整 YAML 如下，保存为 `.github/workflows/workflow-playground-hello.yaml`：

```yaml
name: GitHub Actions Playground - Hello

# 在 GitHub 网页上点击 Run workflow 手动触发
on:
  workflow_dispatch:

permissions:
  contents: read

jobs:
  hello:
    runs-on: ubuntu-latest
    timeout-minutes: 5

    steps:
      - name: 下载仓库代码
        uses: actions/checkout@v6

      - name: 查看执行环境
        run: |
          echo "Hello GitHub Actions!"
          echo "当前仓库：$GITHUB_REPOSITORY"
          uname -a
          ls -la

      - name: 检查入门文档
        run: |
          test -s readme-github-actions.md
          echo "检查通过：入门文档存在且非空。"
```

等待示例保存为 `.github/workflows/workflow-playground-wait.yaml`：

```yaml
name: GitHub Actions Playground - Wait

# 在 GitHub 网页上点击 Run workflow 手动触发
on:
  workflow_dispatch:

permissions: {}

jobs:
  wait:
    runs-on: ubuntu-latest
    timeout-minutes: 5

    steps:
      - name: 开始等待示例
        run: echo "准备等待 5 秒。"

      - name: 等待 5 秒
        run: sleep 5

      - name: 等待完成后继续执行
        run: echo "已等待 5 秒，继续执行后续步骤。"
```
