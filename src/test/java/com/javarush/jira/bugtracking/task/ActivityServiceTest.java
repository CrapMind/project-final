package com.javarush.jira.bugtracking.task;
import com.javarush.jira.BaseTests;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import java.time.Duration;
import java.time.LocalDateTime;
import java.util.Arrays;
import java.util.List;
import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.mockito.Mockito.when;

public class ActivityServiceTest extends BaseTests {
    @InjectMocks
    private ActivityService activityService;
    @Mock
    private final Task task = new Task(1L, "test", "test", "test", 1L, 1L, 1L);
    private final String IN_PROGRESS_STATUS = "in_progress";
    private final String READY_FOR_REVIEW_STATUS = "ready_for_review";
    private final String DONE_STATUS = "done";
    @BeforeEach
    void setUp() {

        long taskId = task.getId();
        List<Activity> activities = Arrays.asList(
                new Activity(1L, taskId, 1L, LocalDateTime.parse("2023-01-03T07:00:00"),
                        "Comment", IN_PROGRESS_STATUS, "Low", "Bug", "Initial work", "Starting development", 1),
                new Activity(2L, taskId, 1L, LocalDateTime.parse("2023-01-03T08:35:00"), //1h:35m
                        "Comment", READY_FOR_REVIEW_STATUS, "Medium", "Bug", "Review", "Ready for review", 2),
                new Activity(3L, taskId, 1L, LocalDateTime.parse("2023-01-03T09:00:00"), //2h
                        "Comment", IN_PROGRESS_STATUS, "High", "Bug", "Further work", "Continuing development", 3),
                new Activity(4L, taskId, 1L, LocalDateTime.parse("2023-01-03T10:00:00"), //3h
                        "Comment", READY_FOR_REVIEW_STATUS, "Critical", "Bug", "Final review", "Final checks before done", 4),
                new Activity(5L, taskId, 1L, LocalDateTime.parse("2023-01-03T10:45:00"), //4h
                        "Additional development", IN_PROGRESS_STATUS, "Critical", "Bug", "Further work", "Additional development before final review", 5),
                new Activity(6L, taskId, 1L, LocalDateTime.parse("2023-01-03T11:45:00"), //4h:45m
                        "Final review", READY_FOR_REVIEW_STATUS, "Critical", "Bug", "Final checks", "Final review before completion", 6),
                new Activity(7L, taskId, 1L, LocalDateTime.parse("2023-01-03T12:55:00"), //5h:55m
                        "Comment", DONE_STATUS, "High", "Bug", "Completion", "Task completed successfully", 5)
        );

        when(task.getActivities()).thenReturn(activities);
    }

    @Test
    public void testCalculateTimeInProgress() { //calculate the time that a task is in progress before the first review
        Duration result = activityService.calculateTimeInProgress(task);
        assertEquals(Duration.ofHours(1).plusMinutes(35), result); //from first "in progress" before first "ready_for_review"
    }

    @Test
    public void testCalculateTimeInTesting() { //calculate the time a task takes from first review to done
        Duration result = activityService.calculateTimeInTesting(task);
        assertEquals(Duration.ofHours(4).plusMinutes(20), result); //from first "ready_for_review" before "done"
    }
    @Test
    public void testCalculateTotalDevelopmentTime() { //calculate all the time the task was in development
        Duration expectedDuration = Duration.ofHours(5).plus(Duration.ofMinutes(55)); // 5 hours and 55 minutes in development
        Duration actualDuration = activityService.calculateTotalDevelopmentTime(task);
        assertEquals(expectedDuration, actualDuration, "The calculated development time should match expected.");
    }
}
