class SessionsController < ApplicationController
  before_action :set_session, only: [:show, :edit, :update, :destroy]
  skip_before_action :verify_authenticity_token, only: [:klik, :options]

  # GET /sessions
  # GET /sessions.json
  def index
    @sessions = Session.all
  end

  # GET /sessions/1
  # GET /sessions/1.json
  def show
    @teams = Team.leaderboard
  end

  # GET /sessions/new
  def new
    @session = Session.new(
      session_string: Session.suggest_random_sessions_string,
      click_count: 0
    )
  end

  # GET /sessions/admin_new
  def admin_new
    @session = Session.new
  end

  # GET /sessions/1/edit
  def edit
  end

  # POST /api/v1/klik
  def klik
    # cannot klik if params are empty
    respond_to :json
    if klik_params[:session].blank?
      render json: '', status: :unprocessable_entity
      return 
    end

    # find out team from team_name or create new team
    team_in_request = Team.find_or_create_by(name: klik_params[:team])

    # find out or create session
    if @session = Session.find_by(session_string: klik_params[:session]) 
      if @session.team != team_in_request
        # this is unspecified by specification, we can either throw an error
        # or adjust session team to match request team
        # currently doing the second one (in update session part)
      end
    else
      @session = Session.create(session_string: klik_params[:session], team_id: team_in_request.id )
    end

    # update session
    if @session.update(click_count: (@session.click_count||0)+1, team_id: team_in_request.id )
      render json: {your_clicks: @session.click_count, team_clicks: @session.team.click_count }, status: :ok
    else
      render json: @session.errors, status: :unprocessable_entity
    end

  end

  # POST /sessions/1/test_klik
  def test_klik
    @session = Session.find(params[:id])

    respond_to do |format|
      if @session.update(click_count: (@session.click_count||0)+1 )
        format.html { redirect_to @session }
        format.json { render :show, status: :ok, location: @session }
      else
        format.html { render :edit }
        format.json { render json: @session.errors, status: :unprocessable_entity }
      end
    end

  end


  # POST /sessions
  # POST /sessions.json
  def create
    # default clicks to 0 (unless specified)
    session_params_hash = session_params.to_h
    session_params_hash[:click_count] = 1 unless session_params_hash[:click_count]

    # find out team_id from team_name
    if params[:team_name].empty?
      redirect_to teams_path, notice: "Jméno teamu nemůže být prázdně"
    else
      team = Team.find_or_create_by(name: params[:team_name])
      session_params_hash = session_params_hash.merge(team_id: team.id)

      # create session
      @session = Session.new(session_params_hash)

      respond_to do |format|
        if @session.save
          format.html { redirect_to @session, notice: 'Můžeš začít klikat o 106' }
          format.json { render :show, status: :created, location: @session }
        else
          format.html { redirect_to 'teams#index' }
          format.json { render json: @session.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # PATCH/PUT /sessions/1
  # PATCH/PUT /sessions/1.json
  def update
    respond_to do |format|
      if @session.update(session_params)
        format.html { redirect_to @session, notice: 'Session was successfully updated.' }
        format.json { render :show, status: :ok, location: @session }
      else
        format.html { render :edit }
        format.json { render json: @session.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /sessions/1
  # DELETE /sessions/1.json
  def destroy
    @session.destroy
    respond_to do |format|
      format.html { redirect_to sessions_url, notice: 'Session was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_session
      @session = Session.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def session_params
      params.require(:session).permit(:session_string, :click_count, :team_id)
    end

    def klik_params
      # if params area empty it might be because Content-Type is wrong
      # we can try parse request ourselves
      if params.blank? or params[:team].nil?
        pom = JSON.parse(request.raw_post)
        if pom.nil?
          return []
        else
          return { team: pom['team'], session: pom['session'] }
        end
      else
        params.require(:team)
        params.require(:session)
        params.permit(:team,:session)
      end
    end
end
