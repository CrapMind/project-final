package com.javarush.jira.profile.internal.web;
import com.javarush.jira.AbstractControllerTest;
import com.javarush.jira.common.BaseHandler;
import static com.javarush.jira.common.util.JsonUtil.writeValue;
import com.javarush.jira.profile.ProfileTo;
import com.javarush.jira.profile.internal.ProfileMapper;
import com.javarush.jira.profile.internal.ProfileRepository;
import com.javarush.jira.profile.internal.model.Profile;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.security.test.context.support.WithUserDetails;
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders;

import static com.javarush.jira.login.internal.web.UserTestData.*;
import static com.javarush.jira.profile.internal.web.ProfileTestData.*;
import static org.springframework.test.web.servlet.result.MockMvcResultHandlers.print;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;


class ProfileRestControllerTest extends AbstractControllerTest {
    @Autowired
    ProfileRepository profileRepository;
    @Autowired
    ProfileMapper profileMapper;
    private final String PROFILE_REST_URL = BaseHandler.REST_URL + "/profile";


    @Test
    @WithUserDetails(value = USER_MAIL)
    void getUserProfile() throws Exception {
        perform(MockMvcRequestBuilders.get(PROFILE_REST_URL))
                .andExpect(status().isOk())
                .andDo(print())
                .andExpect(content().contentTypeCompatibleWith(MediaType.APPLICATION_JSON))
                .andExpect(PROFILE_TO_MATCHER.contentJson(USER_PROFILE_TO));
    }
    @Test
    @WithUserDetails(value = ADMIN_MAIL)
    void getAdminProfile() throws Exception {
        perform(MockMvcRequestBuilders.get(PROFILE_REST_URL))
                .andExpect(status().isOk())
                .andDo(print())
                .andExpect(content().contentTypeCompatibleWith(MediaType.APPLICATION_JSON))
                .andExpect(PROFILE_TO_MATCHER.contentJson(ADMIN_PROFILE_TO));
    }
    @Test
    @WithUserDetails(value = GUEST_MAIL)
    void getGuestProfile() throws Exception {
        perform(MockMvcRequestBuilders.get(PROFILE_REST_URL))
                .andExpect(status().isOk())
                .andDo(print())
                .andExpect(content().contentTypeCompatibleWith(MediaType.APPLICATION_JSON))
                .andExpect(PROFILE_TO_MATCHER.contentJson(GUEST_PROFILE_EMPTY_TO));
    }
    @Test
    @WithUserDetails(value = MANAGER_MAIL)
    void getManagerProfile() throws Exception {
        perform(MockMvcRequestBuilders.get(PROFILE_REST_URL))
                .andExpect(status().isOk())
                .andDo(print())
                .andExpect(content().contentTypeCompatibleWith(MediaType.APPLICATION_JSON))
                .andExpect(PROFILE_TO_MATCHER.contentJson(MANAGER_PROFILE_EMPTY_TO));
    }
    @Test
    void getUnauthorized() throws Exception {
        perform(MockMvcRequestBuilders.get(PROFILE_REST_URL))
                .andExpect(status().isUnauthorized())
                .andDo(print());
    }
    @Test
    @WithUserDetails(value = MANAGER_MAIL)
    void createProfile() throws Exception {
        Profile newProfile = getNew(4);
        ProfileTo newProfileTo = profileMapper.toTo(newProfile);
        perform(MockMvcRequestBuilders.put(PROFILE_REST_URL)
                .contentType(MediaType.APPLICATION_JSON)
                .content(writeValue(newProfileTo)))
                .andExpect(status().isNoContent());
    }






}