require "sinatra"
require "pg"
require "pry"

system 'psql contact_list_development < schema.sql'
system 'psql contact_list_development < data.sql'

configure :development do
  set :db_config, { dbname: "contact_list_development" }
end

configure :test do
  set :db_config, { dbname: "contact_list_test" }
end

def db_connection
  begin
    connection = PG.connect(Sinatra::Application.db_config)
    yield(connection)
  ensure
    connection.close
  end
end

def contacts_all
  db_connection do |conn|
    sql_query = "SELECT * FROM contacts"
    conn.exec(sql_query)
  end
end

def contacts_save(params)
  unless params['name'].empty?
    db_connection do |conn|
      sql_query = "INSERT INTO contacts (name) VALUES ($1)"
      data = [params['name']]
      conn.exec_params(sql_query, data)
    end
  end
end

def get_contact_id(id)
  db_connection do |conn|
    sql_query = "SELECT * FROM contacts WHERE id = ($1)"
    data = [id]
    conn.exec_params(sql_query, data).first
  end
end

def skills_save(params)
    db_connection do |conn|
      sql_query = "INSERT INTO skills (description) VALUES ($1)"
      data = [params['description']]
      conn.exec_params(sql_query, data)
    end
end

def get_skills_by_id(id)
  db_connection do |conn|
    sql_query = "SELECT contacts.name, skills.description
                FROM contacts
                JOIN skills
                ON contacts.id = skills.contact_id
                WHERE contacts.id = ($1)"
    data = [id]
    conn.exec_params(sql_query, data)
  end
end

get "/" do
  redirect "/contacts"
end

get "/contacts" do
  @contacts = contacts_all
  erb :contacts
end

post "/contacts" do
  contacts_save(params)
  skills_save(params)
  redirect "/contacts"
end

get "/contacts/:id" do
  @contact = get_contact_id(params[:id])
  @skills = get_skills_by_id(params[:id].to_i).to_a
  erb :show
end
