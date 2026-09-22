<%@ page contentType="text/html;charset=UTF-8" %>

<%@ taglib prefix="c"
           uri="jakarta.tags.core" %>

<!DOCTYPE html>

<html>

<head>

    <title>Employee Management</title>

</head>

<body>

<h1>Employee Management System</h1>

<a href="${pageContext.request.contextPath}/employees?action=new">
    Add Employee
</a>

<table border="1">

    <tr>
        <th>ID</th>
        <th>Name</th>
        <th>Email</th>
        <th>Department</th>
        <th>Salary</th>
        <th>Action</th>
    </tr>

    <c:forEach var="employee" items="${employees}">

        <tr>

            <td>${employee.id}</td>
            <td>${employee.name}</td>
            <td>${employee.email}</td>
            <td>${employee.department}</td>
            <td>${employee.salary}</td>

            <td>

                <a href="${pageContext.request.contextPath}/employees?action=edit&id=${employee.id}">
                    Edit
                </a>

                <a href="${pageContext.request.contextPath}/employees?action=delete&id=${employee.id}"
                   onclick="return confirm('Are you sure?')">
                    Delete
                </a>

            </td>

        </tr>

    </c:forEach>

</table>

</body>

</html>