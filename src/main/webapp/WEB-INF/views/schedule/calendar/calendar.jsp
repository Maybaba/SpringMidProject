<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Calendar</title>
  <style>
    .calendar {
      width: 100%;
      border-collapse: collapse;
    }
    .calendar th, .calendar td {
      border: 1px solid #ddd;
      padding: 10px;
      text-align: center;
    }
    .event {
      margin-top: 5px;
      padding: 3px;
      background-color: lightblue;
      border-radius: 3px;
    }
  </style>
</head>
<body>
<h1>Calendar</h1>
<h2>Welcome, <c:out value="${userName}" /></h2>
<h3 id="current-month"></h3>

<div id="calendar"></div>

<script>
  document.addEventListener('DOMContentLoaded', function () {
    // JSON 형식의 문자열을 자바스크립트 객체로 반환
    const myCalEvents = JSON.parse('<c:out value="${mycalEvents}" escapeXml="false" />'); // EL 표현식 사용

    // 첫 번째 이벤트에서 userId 속성을 가져옴
    const userId = myCalEvents.length > 0 ? myCalEvents[0].userId : "";

    const monthNames = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];

    let currentYear = new Date().getFullYear();
    let currentMonth = new Date().getMonth();

    function updateCurrentMonth(year, month) {
      document.getElementById('current-month').textContent = `\${monthNames[month]} \${year}`;
    }

    function fetchEvents(year, month) {
      const xhr = new XMLHttpRequest();
      xhr.open('GET', `/api/calendar/myEvents/\${userId}?year=\${year}&month=\${month + 1}`, true);
      console.log(`/api/calendar/myEvents/\${userId}?year=\${year}&month=\${month + 1}`);

      xhr.onreadystatechange = function () {
        if (xhr.readyState === 4) {
          if (xhr.status === 200) {
            const data = JSON.parse(xhr.responseText);
            renderCalendar(data, year, month);
          } else {
            console.error('Failed to fetch calendar events:', xhr.status, xhr.statusText);
          }
        }
      };
      xhr.send();
    }

    function renderCalendar(events, year, month) {
      const firstDay = new Date(year, month, 1).getDay();
      const lastDate = new Date(year, month + 1, 0).getDate();

      let calendarHtml = '<table class="calendar">';
      calendarHtml += '<tr>';
      calendarHtml += '<th>Sun</th><th>Mon</th><th>Tue</th><th>Wed</th><th>Thu</th><th>Fri</th><th>Sat</th>';
      calendarHtml += '</tr><tr>';

      for (let i = 0; i < firstDay; i++) {
        calendarHtml += '<td></td>';
      }

      for (let date = 1; date <= lastDate; date++) {
        const day = (firstDay + date - 1) % 7;
        if (day === 0 && date > 1) {
          calendarHtml += '</tr><tr>';
        }

        const yearStr = year.toString();
        const monthStr = (month + 1 < 10 ? '0' + (month + 1) : month + 1).toString();
        const dateStr = (date < 10 ? '0' + date : date).toString();

        const fullDateStr = `\${yearStr}-\${monthStr}-\${dateStr}`;

        calendarHtml += `<td><div>\${date}</div>`;

        events.forEach(event => {
          if (event.calEventDate.startsWith(fullDateStr)) {
            calendarHtml += `<div class="event">${event.calEventTitle}</div>`;
          }
        });
        calendarHtml += '</td>';
      }

      calendarHtml += '</tr></table>';

      document.getElementById('calendar').innerHTML = calendarHtml;
      updateCurrentMonth(year, month);
    }

    document.getElementById('prev-month').addEventListener('click', function () {
      if (currentMonth === 0) {
        currentYear--;
        currentMonth = 11;
      } else {
        currentMonth--;
      }
      fetchEvents(currentYear, currentMonth);
    });

    document.getElementById('next-month').addEventListener('click', function () {
      if (currentMonth === 11) {
        currentYear++;
        currentMonth = 0;
      } else {
        currentMonth++;
      }
      fetchEvents(currentYear, currentMonth);
    });

    // 초기 이벤트 및 현재 달 렌더링
    renderCalendar(myCalEvents, currentYear, currentMonth);
  });
</script>

<div>Formatted Date: <span id="formattedDate"><c:out value="${formattedDate}" /></span></div>

<button id="prev-month">Prev</button>
<button id="next-month">Next</button>
</body>
</html>
