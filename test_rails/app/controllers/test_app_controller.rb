class TestAppController < ApplicationController
  def index
    render body: 'TestAppBody'
  end
end
