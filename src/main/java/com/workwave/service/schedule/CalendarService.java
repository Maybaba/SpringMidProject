package com.workwave.service.schedule;

import com.workwave.dto.schedule_dto.request.AllMyCalendarEventDto;
import com.workwave.dto.schedule_dto.request.CalendarsDto;
import com.workwave.dto.schedule_dto.request.AllMyTeamCalendarEventDto;
import com.workwave.mapper.scheduleMapper.CalendarMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.Calendar;
import java.util.List;

@RequiredArgsConstructor
@Service
public class CalendarService {

        private final CalendarMapper calendarMapper;

    //user의 모든 캘린더 목록 (총 2개)
    public List<CalendarsDto> getCalendars(String userId) {
        return calendarMapper.getMyAllCalendars(userId);
    }

    // 달 별로 개인 일정 불러오기
        public List<AllMyCalendarEventDto> getMyEventsForMonth(String userId, int year, int month) {
            // startDate는 해당 연도의 해당 월의 첫 번째 날
            String startDate = String.format("%d-%02d-01", year, month);
            // endDate는 해당 연도의 해당 월의 마지막 날
            String endDate = String.format("%d-%02d-%02d", year, month, getLastDayOfMonth(year, month));
              return calendarMapper.getCalendarEventsForPeriod(userId, startDate, endDate);
        }

    // 해당 연도와 월의 마지막 날짜를 가져오는 헬퍼 메서드
        private int getLastDayOfMonth(int year, int month) {
            Calendar cal = Calendar.getInstance();
            cal.set(year, month - 1, 1);
                return cal.getActualMaximum(Calendar.DAY_OF_MONTH);
        }


        //개인 캘린더 일정 목록
        public List<AllMyCalendarEventDto> getMyAllEvents(String userId) {
            return calendarMapper.getMyAllCalendarEvents(userId);
        }

    //개인 캘린더 일정 추가
    public void addMyEvent(AllMyCalendarEventDto myCalendarEventDto) {
        myCalendarEventDto.builder()
                .calEventDate(LocalDateTime.now())
                .calEventTitle("None")
                .calEventDescription("None")
                .calEventCreateAt(LocalDateTime.now())
                .calEventUpdateAt(LocalDateTime.now())
                .colorIndexId(1) //기본값
                .build();
    }
    //개인 캐캘린더 일정 수정
    public void updateMyCalEvent(AllMyCalendarEventDto allMyCalendarEvent) {
        calendarMapper.updateCalendarEvent(allMyCalendarEvent);
    }

    //개인 캘린더 일정 삭제
    public void deleteMyCalEvent(int calEventId) {
        calendarMapper.deleteCalendarEvent(calEventId);
    }

    //팀 캘린더 일정 목록
    public List<AllMyTeamCalendarEventDto> getMyTeamEvents(String departmentId) {return calendarMapper.getMyAllTeamCalendarEvents(departmentId);
    }








    }
