<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <title>DevOps certification: stage is up</title>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Arial, sans-serif;
            background: #101820;
            color: #f2f2f2;
            display: flex;
            align-items: center;
            justify-content: center;
            min-height: 100vh;
            margin: 0;
        }
        main {
            text-align: center;
            padding: 2rem 3rem;
            border: 1px solid #2e3b47;
            border-radius: 12px;
            background: #17222c;
        }
        h1 { color: #4cd964; margin-bottom: .5rem; }
        code { color: #7fd1ff; }
    </style>
</head>
<body>
<main>
    <h1>Congratulations!</h1>
    <h2>Java application is running on the stage environment.</h2>
    <p>Deployed by Jenkins &middot; Terraform &middot; Ansible &middot; Docker</p>
    <p>Health endpoint: <code>/hello/hello</code></p>
</main>
</body>
</html>
