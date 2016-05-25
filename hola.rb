require 'bundler/setup'
require 'sinatra'
require "sqlite3"

# Open a database
DB = SQLite3::Database.new "db/test.db"

=begin
rows = DB.execute <<-SQL
  create table usos (
    producto varchar(30),
    unidades int
  );
SQL
=end

def agregar_compra(producto, unidades = 1)
  DB.execute("insert into compras values ( ?, ?)", producto, unidades)
end

def registrar_uso(producto, unidades = 1)
  DB.execute("insert into usos values ( ?, ?)", producto, unidades)
end

def obtener_disponibles
  @compras = DB.execute("select * from compras limit 10")
  @usos = DB.execute("select * from usos limit 10")

  resultado = []

  if @compras.empty?
    return resultado
  end

  @compras.each do |compra|
    unidades = compra[1]

    @usos.each do |uso|
      if uso[0] == compra[0]
        unidades -= uso[1]
      end
    end

    resultado << [compra[0], unidades]
  end

  resultado
end

get '/' do
  @disponibles = obtener_disponibles
  erb :index
end

# esta pagina muestra el formulario para ingresar una nueva compra
get '/compras' do
  @compras = DB.execute("select * from compras limit 10")
  erb :compras
end

# esta pagina muestra el formulario para ingresar un nuevo uso
get '/usos' do
  @compras = DB.execute("select * from compras limit 10")
  @usos = DB.execute("select * from usos limit 10")

  erb :usos
end

post '/nuevacompra' do
  producto = params[:producto]
  unidades = params[:unidades]

  agregar_compra(producto, unidades)
  redirect to('/compras')
end

post '/nuevouso' do
  producto = params[:producto]
  unidades = params[:unidades]

  registrar_uso(producto, unidades)
  redirect to('/usos')
end