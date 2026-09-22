package com.example.servlet;

import com.example.entity.Employee;
import com.example.util.HibernateUtil;

import jakarta.persistence.EntityManager;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.List;

@WebServlet("/employees")
public class EmployeeServlet extends HttpServlet {

    // =========================
    // READ
    // =========================

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");

        // Show Add Employee Form
        if ("new".equals(action)) {

            request.getRequestDispatcher("employee-form.jsp")
                    .forward(request, response);

        }

        // Show Edit Employee Form
        else if ("edit".equals(action)) {

            int id = Integer.parseInt(request.getParameter("id"));

            EntityManager em = HibernateUtil.getEntityManager();

            Employee employee = em.find(Employee.class, id);

            em.close();

            request.setAttribute("employee", employee);

            request.getRequestDispatcher("employee-form.jsp")
                    .forward(request, response);

        }

        // Delete Employee
        else if ("delete".equals(action)) {

            int id = Integer.parseInt(request.getParameter("id"));

            EntityManager em = HibernateUtil.getEntityManager();

            em.getTransaction().begin();

            Employee employee = em.find(Employee.class, id);

            if (employee != null) {
                em.remove(employee);
            }

            em.getTransaction().commit();

            em.close();

            response.sendRedirect(
                    request.getContextPath() + "/employees"
            );

        }

        // Display All Employees
        else {

            EntityManager em = HibernateUtil.getEntityManager();

            List<Employee> employees =
                    em.createQuery(
                            "SELECT e FROM Employee e",
                            Employee.class
                    ).getResultList();

            em.close();

            request.setAttribute("employees", employees);

            request.getRequestDispatcher("employees.jsp")
                    .forward(request, response);
        }
    }


    // =========================
    // CREATE + UPDATE
    // =========================

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String id = request.getParameter("id");

        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String department = request.getParameter("department");
        double salary =
                Double.parseDouble(request.getParameter("salary"));

        EntityManager em = HibernateUtil.getEntityManager();

        em.getTransaction().begin();

        // CREATE
        if (id == null || id.isEmpty()) {

            Employee employee = new Employee();

            employee.setName(name);
            employee.setEmail(email);
            employee.setDepartment(department);
            employee.setSalary(salary);

            em.persist(employee);
        }

        // UPDATE
        else {

            Employee employee =
                    em.find(Employee.class,
                            Integer.parseInt(id));

            if (employee != null) {

                employee.setName(name);
                employee.setEmail(email);
                employee.setDepartment(department);
                employee.setSalary(salary);

                em.merge(employee);
            }
        }

        em.getTransaction().commit();

        em.close();

        response.sendRedirect(
                request.getContextPath() + "/employees"
        );
    }
}