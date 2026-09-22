<%@ page contentType="text/html;charset=UTF-8" %>

<!DOCTYPE html>

<html>

<head>

    <title>Employee Form</title>

    <style>

        body {
            font-family: Arial;
            margin: 40px;
        }

        form {
            width: 400px;
        }

        label {
            display: block;
            margin-top: 15px;
        }

        input {
            width: 100%;
            padding: 8px;
            margin-top: 5px;
        }

        button {
            margin-top: 20px;
            padding: 10px 20px;
        }

    </style>

</head>

<body>

<%

    boolean edit = request.getAttribute("employee") != null;

%>

<h1>

    <%= edit ? "Edit Employee" : "Add Employee" %>

</h1>


<form method="post"
      action="${pageContext.request.contextPath}/employees">


    <!-- Employee ID -->

    <input type="hidden"
           name="id"
           value="${employee.id}">


    <!-- Name -->

    <label>Name</label>

    <input type="text"
           name="name"
           value="${employee.name}"
           required>


    <!-- Email -->

    <label>Email</label>

    <input type="email"
           name="email"
           value="${employee.email}"
           required>


    <!-- Department -->

    <label>Department</label>

    <input type="text"
           name="department"
           value="${employee.department}"
           required>


    <!-- Salary -->

    <label>Salary</label>

    <input type="number"
           name="salary"
           step="0.01"
           value="${employee.salary}"
           required>


    <button type="submit">

        <%= edit ? "Update Employee" : "Add Employee" %>

    </button>

</form>


<br>

<a href="${pageContext.request.contextPath}/employees">

    Back to Employee List

</a>

</body>

</html>