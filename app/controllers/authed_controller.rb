class AuthedController < ApplicationController
  before_filter :authenticate_user!
end