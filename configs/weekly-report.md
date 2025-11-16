# Generate Weekly Report

Generate a weekly report based on the provided git logs.

## Instructions

Follow this systematic approach to generate a weekly report: **$ARGUMENTS**

You can execute the following git commands to gather commit data for the specified week:
```bash
git log --since="1 week ago" --author="yangwb"
```

1. **Git Log Analysis**
    - Commit messages and code changes
    - Key features or modules developed
    - Bug fixes and optimizations
    - Merge requests and code reviews
    - Cross-team collaborations

2. **Calculate Weekday range**
    - Calculate the weekday range it falls into based on the timestamp of the most recent commit.

3. **Weekly Report Template**
weekly-report-template.md:
```markdown
    标题：【智能产品研发中心-算法实验室】杨伟彬周报1110-1114（1110-1114指11月10号-11月14号）
    本周重点工作：列出已完成的主线任务、关键成果数据、重要里程碑、跨团队协作事项、遇到并解决的技术难题
    下周工作计划：拆分待推进项目的阶段目标、关键交付物、风险点及应对策略、需要外部支持的事项
    工作思考：总结经验教训、算法/模型优化思路、流程或工具改进建议、对团队协作或资源配置的反馈
```

4. **Weekly Report Generation**
    - Use the git log analysis to generate a weekly report
    - Use the weekly report template to format the report
    - Maintain an objective, neutral, and professional tone.
    - Save the generated report as weekly-report.md
    - The generated report must contain fewer than 700 Chinese characters.

