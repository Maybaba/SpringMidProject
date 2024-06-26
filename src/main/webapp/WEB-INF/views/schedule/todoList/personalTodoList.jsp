<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en" ng-app="myApp">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Personal Todo List</title>
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.4.1/css/bootstrap.min.css">
    <style>
        .app-container {
            height: 100vh;
            width: 100%;
        }
        .complete {
            text-decoration: line-through;
        }
    </style>
</head>
<body ng-controller="myController" class="app-container d-flex align-items-center justify-content-center flex-column">

<h3 class="mb-4">Personal Todo List</h3>

<div class="input-group mb-3">
    <input ng-model="yourTask" type="text" class="form-control" placeholder="Enter a task here">
    <div class="input-group-append">
        <button class="btn btn-primary" type="button" ng-click="saveTask()">Save</button>
    </div>
</div>

<div class="table-responsive">
    <table class="table table-hover table-bordered">
        <thead class="thead-dark">
        <tr>
            <th scope="col">No.</th>
            <th scope="col">Todo item</th>
            <th scope="col">Status</th>
            <th scope="col">Actions</th>
        </tr>
        </thead>
        <tbody>
        <tr ng-repeat="task in tasks" ng-class="{'table-success': task.todoStatus, 'table-light': !task.todoStatus}">
            <td>{{$index + 1}}</td>
            <td ng-class="{'complete': task.todoStatus}">{{task.todoContent}}</td>
            <td>{{task.todoStatus ? 'Completed' : 'In progress'}}</td>
            <td>
                <button ng-click="edit(task)">Edit</button>
                <button class="btn btn-danger btn-sm" ng-click="delete($index)">Delete</button>
                <button class="btn btn-success btn-sm" ng-click="finished($index)">Finished</button>
            </td>
        </tr>
        </tbody>
    </table>
</div>

<!-- 수정 폼 -->
<div ng-if="editingTask">
    <h4>Edit Task</h4>
    <div class="input-group mb-3">
        <input ng-model="editingTask.todoContent" type="text" class="form-control">
        <div class="input-group-append">
            <button class="btn btn-primary" type="button" ng-click="update()">Update</button>
        </div>
    </div>
</div>

<script src="https://ajax.googleapis.com/ajax/libs/angularjs/1.7.9/angular.min.js"></script>
<script>
    var app = angular.module("myApp", []);

    app.controller("myController", function($scope, $http) {
        // 초기화 함수: 서버에서 개인 투두리스트 가져오기
        function init() {
            var userId = '<%= request.getAttribute("userId") %>'; // userId 가져오기

            $http.get('/api/todos/personal/' + userId)
                .then(function(response) {
                    $scope.tasks = response.data;
                })
                .catch(function(error) {
                    console.error('Error fetching tasks:', error);
                });
        }

        init(); // 페이지 로딩 시 초기화 함수 호출

        // 투두리스트 저장 함수
        $scope.saveTask = function() {
            var newTask = {
                todoContent: $scope.yourTask,
                todoStatus: false,
                userId: '<%= request.getAttribute("userId") %>'
            };

            $http.post('/api/todos/personal', newTask)
                .then(function(response) {
                    $scope.tasks.push(response.data); // 추가된 투두리스트를 배열에 추가
                    $scope.yourTask = ''; // 입력 필드 초기화
                })
                .catch(function(error) {
                    console.error('Error saving task:', error);
                });
        };

        // 투두리스트 삭제 함수
        $scope.delete = function(index) {
            var todoId = $scope.tasks[index].todoId;

            $http.delete('/api/todos/personal/' + todoId)
                .then(function(response) {
                    $scope.tasks.splice(index, 1); // 배열에서 삭제
                })
                .catch(function(error) {
                    console.error('Error deleting task:', error);
                });
        };

        // 투두리스트 완료 함수
        $scope.finished = function(index) {
            var todoId = $scope.tasks[index].todoId;

            $http.put('/api/todos/personal/' + todoId, $scope.tasks[index])
                .then(function(response) {
                    $scope.tasks[index] = response.data; // 상태 업데이트된 투두리스트로 업데이트
                })
                .catch(function(error) {
                    console.error('Error updating task:', error);
                });
        };

    // AngularJS Controller에서 edit 함수 추가
    $scope.edit = function(task) {
        $http.get('/api/todos/personal/' + task.todoId)
            .then(function(response) {
                $scope.editingTask = response.data;
            })
            .catch(function(error) {
                console.error('Error fetching task to edit:', error);
            });
    };

    // 투두리스트 수정 처리 함수
    $scope.update = function() {
        $http.put('/api/todos/personal/' + $scope.editingTask.todoId, $scope.editingTask)
            .then(function(response) {
                // 수정된 투두리스트로 tasks 배열 업데이트
                var index = $scope.tasks.findIndex(function(task) {
                    return task.todoId === $scope.editingTask.todoId;
                });
                if (index !== -1) {
                    $scope.tasks[index] = response.data;
                }
                $scope.editingTask = null; // 수정 상태 초기화
            })
            .catch(function(error) {
                console.error('Error updating task:', error);
            });
        };
    });
</script>

<script src="https://code.jquery.com/jquery-3.4.1.slim.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/popper.js@1.16.0/dist/umd/popper.min.js"></script>
<script src="https://stackpath.bootstrapcdn.com/bootstrap/4.4.1/js/bootstrap.min.js"></script>
</body>
</html>
