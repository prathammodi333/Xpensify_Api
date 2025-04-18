class FriendRequestsController < ApplicationController
  before_action :authenticate_user!, except: :accept

  def create
    email = params[:email].downcase.strip
    recipient = User.find_by(email: email)

    if recipient
      FriendRequestMailer.request_existing_user(current_user, recipient).deliver_now
      respond_to do |format|
        format.turbo_stream {
          flash.now[:notice] = "Friend request sent to #{recipient.name}"
          render turbo_stream: turbo_stream.append("notifications", partial: "shared/flash")
        }
        format.html { redirect_to dashboard_path, notice: "Friend request sent to #{recipient.name}" }
      end
    else
      FriendRequestMailer.invite_new_user(current_user, email).deliver_now
      respond_to do |format|
        format.turbo_stream {
          flash.now[:notice] = "Invitation sent to #{email}"
          render turbo_stream: turbo_stream.append("notifications", partial: "shared/flash")
        }
        format.html { redirect_to dashboard_path, notice: "Invitation sent to #{email}" }
      end
    end
  end

  def accept
    if user_signed_in?
      sender = User.find_by(id: params[:sender_id])
      if sender && !current_user.all_friends.include?(sender)
        Friendship.create(user: current_user, friend: sender)
        Friendship.create(user: sender, friend: current_user)
        redirect_to dashboard_path, notice: "You are now friends with #{sender.name}!"
      else
        redirect_to dashboard_path, alert: "Invalid friend request."
      end
    else
      session[:pending_friend_request_sender_id] = params[:sender_id]
      redirect_to new_user_session_path, alert: "Please log in to accept the friend request."
    end
  end
end