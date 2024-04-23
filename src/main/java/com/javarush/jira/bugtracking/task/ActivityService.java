package com.javarush.jira.bugtracking.task;

import com.javarush.jira.bugtracking.Handlers;
import com.javarush.jira.bugtracking.task.to.ActivityTo;
import com.javarush.jira.common.error.DataConflictException;
import com.javarush.jira.login.AuthUser;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Duration;
import java.time.LocalDateTime;
import java.util.Comparator;
import java.util.List;

import static com.javarush.jira.bugtracking.task.TaskUtil.getLatestValue;

@Service
@RequiredArgsConstructor
public class ActivityService {
    private final TaskRepository taskRepository;

    private final Handlers.ActivityHandler handler;
    private final String READY_FOR_REVIEW_STATUS = "ready_for_review";
    private final String IN_PROGRESS_STATUS = "in_progress";
    private final String DONE_STATUS = "done";


    private static void checkBelong(HasAuthorId activity) {
        if (activity.getAuthorId() != AuthUser.authId()) {
            throw new DataConflictException("Activity " + activity.getId() + " doesn't belong to " + AuthUser.get());
        }
    }

    @Transactional
    public Activity create(ActivityTo activityTo) {
        checkBelong(activityTo);
        Task task = taskRepository.getExisted(activityTo.getTaskId());
        if (activityTo.getStatusCode() != null) {
            task.checkAndSetStatusCode(activityTo.getStatusCode());
        }
        if (activityTo.getTypeCode() != null) {
            task.setTypeCode(activityTo.getTypeCode());
        }
        return handler.createFromTo(activityTo);
    }

    @Transactional
    public void update(ActivityTo activityTo, long id) {
        checkBelong(handler.getRepository().getExisted(activityTo.getId()));
        handler.updateFromTo(activityTo, id);
        updateTaskIfRequired(activityTo.getTaskId(), activityTo.getStatusCode(), activityTo.getTypeCode());
    }

    @Transactional
    public void delete(long id) {
        Activity activity = handler.getRepository().getExisted(id);
        checkBelong(activity);
        handler.delete(activity.id());
        updateTaskIfRequired(activity.getTaskId(), activity.getStatusCode(), activity.getTypeCode());
    }

    private void updateTaskIfRequired(long taskId, String activityStatus, String activityType) {
        if (activityStatus != null || activityType != null) {
            Task task = taskRepository.getExisted(taskId);
            List<Activity> activities = handler.getRepository().findAllByTaskIdOrderByUpdatedDesc(task.id());
            if (activityStatus != null) {
                String latestStatus = getLatestValue(activities, Activity::getStatusCode);
                if (latestStatus == null) {
                    throw new DataConflictException("Primary activity cannot be delete or update with null values");
                }
                task.setStatusCode(latestStatus);
            }
            if (activityType != null) {
                String latestType = getLatestValue(activities, Activity::getTypeCode);
                if (latestType == null) {
                    throw new DataConflictException("Primary activity cannot be delete or update with null values");
                }
                task.setTypeCode(latestType);
            }
        }
    }
    public Duration calculateTotalDevelopmentTime(Task task) {
        List<Activity> activities = task.getActivities().stream()
                .sorted(Comparator.comparing(Activity::getUpdated))
                .toList();

        Duration totalDevelopmentTime = Duration.ZERO;
        LocalDateTime lastInProgressTime = null;
        LocalDateTime lastReviewTime = null;

        for (Activity activity : activities) {
            if (activity.getStatusCode() != null) {
                switch (activity.getStatusCode()) {
                    case IN_PROGRESS_STATUS -> {
                        lastInProgressTime = activity.getUpdated();
                        if (lastReviewTime != null) {
                            totalDevelopmentTime = totalDevelopmentTime.plus(Duration.between(lastReviewTime, lastInProgressTime));
                        }
                    }
                    case READY_FOR_REVIEW_STATUS -> {
                        if (lastInProgressTime != null) {
                            lastReviewTime = activity.getUpdated();
                            totalDevelopmentTime = totalDevelopmentTime.plus(Duration.between(lastInProgressTime, lastReviewTime));
                        }
                    }
                    case DONE_STATUS -> {
                        if (lastReviewTime != null) {
                            totalDevelopmentTime = totalDevelopmentTime.plus(Duration.between(lastReviewTime, activity.getUpdated()));
                        }
                    }
                    default ->
                            throw new IllegalStateException("No activity found for task " + task.getId() + " with status " + activity.getStatusCode());
                }
            }
        }
        return totalDevelopmentTime;
    }

    public Duration calculateTimeInProgress(Task task) {
        LocalDateTime startTime = getTimeForStatus(task, IN_PROGRESS_STATUS);
        LocalDateTime endTime = getTimeForStatus(task, READY_FOR_REVIEW_STATUS);
        return Duration.between(startTime, endTime);
    }
    public Duration calculateTimeInTesting(Task task) {
        LocalDateTime startTime = getTimeForStatus(task, READY_FOR_REVIEW_STATUS);
        LocalDateTime endTime = getTimeForStatus(task, DONE_STATUS);
        return Duration.between(startTime, endTime);
    }
    private LocalDateTime getTimeForStatus(Task task, String statusCode) {
        return task.getActivities().stream()
                .filter(a -> statusCode.equals(a.getStatusCode()))
                .min(Comparator.comparing(Activity::getUpdated))
                .map(Activity::getUpdated)
                .orElseThrow(() -> new IllegalStateException("No activity found for task " + task.getId() + " with status " + statusCode));
    }

}
