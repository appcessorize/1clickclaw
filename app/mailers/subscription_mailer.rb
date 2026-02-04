# frozen_string_literal: true

class SubscriptionMailer < ApplicationMailer
  def welcome(user)
    @user = user
    mail(to: @user.email, subject: "Welcome to ClawSaaS!")
  end

  def trial_ending(user)
    @user = user
    @days_remaining = @user.days_remaining_in_trial
    mail(to: @user.email, subject: "Your trial ends in #{@days_remaining} days")
  end

  def payment_failed(user)
    @user = user
    mail(to: @user.email, subject: "Action required: Payment failed")
  end

  def subscription_canceled(user)
    @user = user
    mail(to: @user.email, subject: "Your subscription has been canceled")
  end

  def subscription_renewed(user)
    @user = user
    mail(to: @user.email, subject: "Your subscription has been renewed")
  end
end
