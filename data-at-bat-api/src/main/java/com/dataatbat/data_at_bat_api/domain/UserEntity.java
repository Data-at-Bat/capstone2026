package com.dataatbat.data_at_bat_api.domain;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name="users")
public class UserEntity {

    @Getter
    @Setter
    @Id
    @Column(name="uid")
    private UUID uid;

    @Getter
    @Setter
    @Column(nullable = false)
    private String email;

    @Getter
    @Setter
    @Column(name="subscription_status")
    private Boolean subscriptionStatus;

    @Getter
    @Setter
    @Column(name="subscription_expiry")
    private LocalDateTime subscriptionExpiry;

    protected UserEntity() { }

    public UserEntity(String email) {
        this.email = email;
        this.subscriptionStatus = false;
    }

    @Override
    public String toString() {
        return String.format("Id: %s\nEmail: %s\nSubscription Status: %s\nSubscription Expiration: %s",
                (uid != null) ? uid.toString() : "NULL",
                (email != null) ? email : "NULL",
                (subscriptionStatus != null) ? subscriptionStatus.toString() : "false",
                (subscriptionExpiry != null) ? subscriptionExpiry.toString() : "NULL"
        );
    }
}