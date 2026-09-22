# GitHub Actions：从第一次运行到看懂执行机制


**GitHub Actions 让你把自动化流程写进仓库：发生某个事件后，系统安排执行机器，按配置下载代码、运行测试或编译，并展示日志和结果。** 本仓库准备了两个手动触发的练习：Hello 打印执行环境并检查这份文档是否存在且非空；Wait 等待 5 秒后继续执行下一步。

## 1. 先理解几个词

| 名称 | 中文理解 | 本仓库中的例子 |
|---|---|---|
| Workflow | 一整套自动化流程，由 YAML 文件定义 | `.github/workflows/workflow-playground-hello.yaml` |
| Event | 触发流程的事件 | `workflow_dispatch`：手动触发；`push`：推送代码 |
| Job | 流程中的一个任务 | `hello` |
| Step | 任务内的一步操作 | 下载代码、查看环境、检查文档 |
| Runner | 实际执行任务的机器或运行环境 | 本例使用 GitHub 提供的 Ubuntu 虚拟机 |
| Action | 可重复使用的操作组件 | `actions/checkout@v6` 下载仓库代码 |

`uses:` 调用现成的 Action；`run:` 执行你写的命令。工作流可以有多个 Job；没有依赖关系的 Job 可并行运行，同一 Job 内本例的 Steps 按顺序执行。参见 [GitHub Actions 核心概念](https://docs.github.com/en/actions/get-started/understand-github-actions)。

## 2. 谁负责帮我运行？

**本例由 GitHub 提供和维护执行机器。** 这一行决定使用标准的 GitHub 托管 Ubuntu Runner：

```yaml
runs-on: ubuntu-latest
```

运行过程是：

```text
你点击 Run workflow
        ↓
GitHub Actions 接收触发并安排任务
        ↓
GitHub 提供临时 Ubuntu 虚拟机
        ↓
Runner 下载仓库代码 → 执行命令 → 返回日志和结果
        ↓
任务结束，临时执行环境被回收
```

流程启动后，你的电脑关机也不影响这个 GitHub 托管任务。`actions/checkout` 下载的是 GitHub 上对应版本的仓库内容，本机尚未推送的修改不会出现在 Runner 上。临时机器里的普通文件也不会自动保存回仓库。

| 方式 | 谁提供、维护机器？ | 适合什么情况？ |
|---|---|---|
| GitHub-hosted runner | GitHub | 入门、常规编译和测试 |
| Self-hosted runner | 你或公司 | 需要公司内网、特定硬件或自定义环境 |

自托管 Runner 必须先安装、注册并保持在线，单纯把配置改成 `runs-on: self-hosted` 不会自动创建机器。参见 [GitHub 托管 Runner](https://docs.github.com/en/actions/concepts/runners/github-hosted-runners) 与 [自托管 Runner](https://docs.github.com/en/actions/concepts/runners/self-hosted-runners)。

## 3. 免费吗？

**这个练习放在public仓库，使用标准 `ubuntu-latest` Runner，执行本身免费。**

| 场景 | 费用规则 |
|---|---|
| 公开仓库 + 标准 GitHub 托管 Runner | 执行免费 |
| 私有仓库 + GitHub Free | 每月含 2,000 分钟，仓库所有者账户下的私有仓库共享额度 |
| 私有仓库 + GitHub Pro | 每月含 3,000 分钟 |
| Larger runners（更大规格的执行机器） | 收费，公开仓库也一样 |
| 自托管 Runner | GitHub Actions 使用免费，机器和维护成本由你或公司承担 |

以标准 Linux Runner 为例，一个 Job 运行 5 分钟会消耗 5 分钟额度；多个 Job 的执行用量要累计，失败和重新运行也会计入。超额使用可能收费；未绑定有效支付方式时，额度耗尽会停止运行。

运行分钟数与存储额度分别计算：GitHub Free 包含 500 MB 的制品存储额度，与 GitHub Packages 共享；不能把“公开仓库运行免费”理解成所有存储无限免费。本例只打印日志和检查文件，没有上传构建制品。

参见 [GitHub Actions 官方计费说明](https://docs.github.com/en/billing/concepts/product-billing/github-actions)。

## 4. 本仓库有什么？

此文件夹本身就是本地 Git 仓库，分支名为 `main`：

```text
topic-github-actions/
├── .git/                         # 本地版本管理信息
├── .gitignore
├── README.md                     # 仓库首页入口
├── readme-github-actions.md       # 本文
└── .github/
    └── workflows/
        ├── workflow-playground-hello.yaml  # 打印环境并检查文档
        └── workflow-playground-wait.yaml   # 等待 5 秒后继续执行
```

本地 Git 仓库和 GitHub 在线仓库是两份不同位置的仓库。仅在本地保存 YAML 不会启动 GitHub Actions；需要将文件提交、推送到 GitHub，并在那里触发运行。

## 5. 可直接复制的完整工作流

保存为 `.github/workflows/workflow-playground-hello.yaml`。以下内容与本仓库提供的文件一致：

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

`contents: read` 给工作流读取仓库内容的权限；`timeout-minutes: 5` 给这个练习设置 5 分钟的执行上限。`test -s` 检查指定文件存在且非空。`run: |` 表示下面是多行命令，缩进需要保持一致。

工作流文件必须放在 `.github/workflows/` 中，并使用 `.yml` 或 `.yaml` 扩展名。示例使用的 `actions/checkout@v6` 与核实日期的官方入门示例一致。参见 [官方快速入门](https://docs.github.com/en/actions/get-started/quickstart) 和 [工作流语法](https://docs.github.com/en/actions/reference/workflows-and-actions/workflow-syntax)。

第二个工作流保存为 `.github/workflows/workflow-playground-wait.yaml`：

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

`sleep 5` 会暂停当前步骤 5 秒；步骤结束后，Runner 才执行下一步并打印完成消息。这个例子无需读取仓库文件，因此没有下载代码步骤，并使用 `permissions: {}` 关闭仓库 Token 权限。

## 6. 发布到 GitHub，再运行第一次

### 第一步：准备首次本地提交

本地仓库初始化不需要提交署名，但创建 Commit 需要。若 Git 尚未配置 `user.name` 和 `user.email`，先将下面两个占位值替换为你的提交署名及 GitHub 已验证邮箱（或账户提供的 noreply 邮箱）。这些命令只设置当前仓库：

```bash
cd /Users/xixu/Dropbox/nv-work/nv-projects/topic-github-actions

git config user.name "YOUR_NAME"
git config user.email "YOUR_GITHUB_EMAIL"

git add README.md readme-github-actions.md .gitignore .github/workflows/workflow-playground-hello.yaml .github/workflows/workflow-playground-wait.yaml
git commit -m "Add GitHub Actions playground and Chinese guide"
```

这里的 Git 署名配置不等于登录 GitHub；推送时还需要可用的 GitHub 身份认证。

### 第二步：创建 GitHub 远程仓库并推送

在 [GitHub 创建仓库页面](https://github.com/new) 新建名为 `topic-github-actions` 的空仓库，按需要选择公开或私有。因为本地已有文件，远程创建时不要额外勾选 README、`.gitignore` 或 License。

下面使用账号 `iamxuxiao-nvidia`，通过 HTTPS + Personal Access Token（PAT）推送。准备一个有该仓库写权限的 Token；运行 `git push` 后，在 `Password` 提示处粘贴 Token 并按回车，输入时不会显示字符。

```bash
cd /Users/xixu/Dropbox/nv-work/nv-projects/topic-github-actions

git remote set-url origin https://github.com/iamxuxiao-nvidia/topic-github-actions.git

# 出现 Password 提示时粘贴 PAT
git -c credential.helper= -c credential.username=iamxuxiao-nvidia push -u origin main
```

本地已配置 `origin`，因此使用 `git remote set-url` 更新地址；若首次配置且尚无 `origin`，将该行改为 `git remote add origin https://github.com/iamxuxiao-nvidia/topic-github-actions.git`。这些命令只关联已经创建的远程仓库，本身不会在 GitHub 创建仓库。参见 [将本地代码添加到 GitHub](https://docs.github.com/en/migrations/importing-source-code/using-the-command-line-to-import-source-code/adding-locally-hosted-code-to-github)。

`-c credential.helper=` 仅对本次命令禁用凭据助手，`-c credential.username=iamxuxiao-nvidia` 提供登录用户名；Token 在密码提示处输入，不写入命令、远程 URL 或 Git 配置，也不会交给凭据助手保存。后续推送使用相同命令并再次输入 Token。参见 [GitHub Token 命令行用法](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens#using-a-personal-access-token-on-the-command-line) 和 [Git 凭据配置](https://git-scm.com/docs/gitcredentials)。

### 第三步：点击运行并看日志

1. 打开 GitHub 仓库，确认默认分支为 `main`，且能看到 `.github/workflows/workflow-playground-hello.yaml`。
2. 点击 **Actions → GitHub Actions Playground - Hello → Run workflow**。
3. 选择 `main`，再次点击 **Run workflow**。
4. 打开新出现的运行记录，再点击任务 `hello`。
5. 展开各步骤，查看输出；正常情况下最终状态为绿色成功。

要运行等待示例，在 **Actions** 中选择 **GitHub Actions Playground - Wait → Run workflow**，打开任务 `wait`，观察“等待 5 秒”和“等待完成后继续执行”两个步骤的日志。

手动触发要求工作流使用 `workflow_dispatch`，该工作流文件已存在于默认分支，并且操作人有仓库写权限。本例只有手动触发，首次推送后不会自动运行。参见 [手动运行工作流](https://docs.github.com/en/actions/how-tos/manage-workflow-runs/manually-run-a-workflow)。

也可以完全使用网页：在你拥有写权限的 GitHub 仓库里上传本文，再通过 **Add file → Create new file** 创建 `.github/workflows/workflow-playground-hello.yaml`，复制上面的 YAML 并提交到默认分支。随后按同样的 Actions 页面操作运行。

## 7. 两个动手实验

### 实验 A：故意失败，再修复

在工作流最后一步，把原来的检查命令改成检查一个不存在的文件：

```bash
test -f missing.txt
echo "这句话在前一条命令失败后不会执行。"
```

提交并推送修改，然后再次手动运行。你会看到检查步骤失败，日志中显示非零退出码。将命令恢复为 `test -s readme-github-actions.md`，再次提交、推送和运行，就能观察从失败到成功的变化。

默认情况下，普通后续步骤会在前面步骤失败后跳过；本例没有设置 `continue-on-error` 或其他异常处理规则。参见 [工作流语法](https://docs.github.com/en/actions/reference/workflows-and-actions/workflow-syntax)。

### 实验 B：每次推送到 main 都自动运行

将原来的整个 `on:` 区块替换为：

```yaml
on:
  push:
    branches: [main]
  workflow_dispatch:
```

这样既保留手动按钮，也会在推送到 `main` 时自动运行。修改本地文件后执行：

```bash
git add .github/workflows/workflow-playground-hello.yaml
git commit -m "Run playground on pushes to main"
# 出现 Password 提示时粘贴 PAT
git -c credential.helper= -c credential.username=iamxuxiao-nvidia push
```

上述命令在本地仓库目录执行，且已按第 6 节配置远程仓库及首次推送。之后刷新 GitHub 的 Actions 页面观察自动出现的运行记录。触发规则见 [工作流事件](https://docs.github.com/en/actions/reference/workflows-and-actions/events-that-trigger-workflows)。

## 8. 常见问题

| 现象 | 优先检查 |
|---|---|
| 没有 Actions 标签 | 仓库或组织是否禁用了 GitHub Actions |
| 没有 Run workflow 按钮 | 是否配置 `workflow_dispatch`、文件是否在默认分支、自己是否有写权限 |
| 本地修改后，日志还是旧内容 | 修改是否已提交并推送，以及运行时选的是不是对应分支 |
| 文件检查失败 | `readme-github-actions.md` 是否已提交，文件名大小写是否一致，内容是否非空 |
| `git commit` 提示身份未知 | 按第 6 节配置当前仓库的提交署名和邮箱 |
| 修改 YAML 后无法识别 | 文件位置、扩展名和缩进是否正确 |

当前练习的检查命令可以逐步替换成真实项目的测试或编译命令，例如 `pytest`、`npm test` 或 `make`。届时还要根据项目配置语言环境、安装依赖，并把项目代码提交到同一个仓库。
