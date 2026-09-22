<%@ page contentType="text/html;charset=UTF-8" %>

<!DOCTYPE html>

<html>
<head>

    <title>Employee Management System</title>

    <style>

        body {
            font-family: Arial, sans-serif;
            background-color: #f4f4f4;
            margin: 0;
            padding: 0;
        }

        .container {
            width: 80%;
            margin: 100px auto;
            text-align: center;
            background-color: white;
            padding: 50px;
            border-radius: 10px;
            box-shadow: 0 0 10px #ccc;
        }

        h1 {
            color: #333;
        }

        p {
            color: #666;
            font-size: 18px;
        }

        .btn {
            display: inline-block;
            margin-top: 20px;
            padding: 12px 25px;
            background-color: #333;
            color: white;
            text-decoration: none;
            border-radius: 5px;
        }

        .btn:hover {
            background-color: #555;
        }

    </style>

</head>

<body>

<div class="container">

    <h1>Employee Management System</h1>

    <p>
        Welcome to the Employee Management System
    </p>

    <p>
        You can add, view, update and delete employees.
    </p>

    <a class="btn"
       href="${pageContext.request.contextPath}/employees">

        Manage Employees

    </a>

</div>

</body>

</html>