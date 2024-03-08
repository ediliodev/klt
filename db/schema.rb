# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20240227032507) do

  create_table "accesots", force: :cascade do |t|
    t.string "usuario"
    t.string "tipoacceso"
    t.datetime "fechayhora"
    t.string "ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "descripcion"
  end

  create_table "cashboxts", force: :cascade do |t|
    t.string "cantidad"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "contadorests", force: :cascade do |t|
    t.string "totalin"
    t.string "totalout"
    t.string "totalnet"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "contribuyentets", force: :cascade do |t|
    t.string "consorcio"
    t.string "sucursal"
    t.string "siglas"
    t.string "localidad"
    t.string "serialmq"
    t.string "countermeterold"
    t.string "countermeternew"
    t.string "aportemega"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "fondots", force: :cascade do |t|
    t.string "cantidad"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "ganadoresmegajackpots", force: :cascade do |t|
    t.string "fecha"
    t.string "consorcio"
    t.string "sucursal"
    t.string "localidad"
    t.string "serialmq"
    t.string "cantidad"
    t.string "montoxcontribuyente"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "historypostransaccionests", force: :cascade do |t|
    t.string "creditin"
    t.string "cashout"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "jugador"
  end

  create_table "jackpots", force: :cascade do |t|
    t.string "color"
    t.string "totalinold"
    t.string "totalinnow"
    t.string "cantidad"
    t.string "trigger"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "localidadts", force: :cascade do |t|
    t.string "consorcio"
    t.string "sucursal"
    t.string "direccion"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "maquinats", force: :cascade do |t|
    t.integer "tipomaquinat_id"
    t.string "descripcion"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "serial"
    t.datetime "lastseen"
    t.string "activa"
    t.string "consorcio"
    t.string "sucursal"
    t.string "supervisor"
    t.string "usuarioventa"
    t.string "entrada"
    t.string "salida"
    t.index ["tipomaquinat_id"], name: "index_maquinats_on_tipomaquinat_id"
  end

  create_table "mixtransaccionests", force: :cascade do |t|
    t.integer "maquinat_id"
    t.string "tipotransaccion"
    t.string "cantidad"
    t.string "comando"
    t.string "status"
    t.string "descripcion"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["maquinat_id"], name: "index_mixtransaccionests_on_maquinat_id"
  end

  create_table "postransaccionests", force: :cascade do |t|
    t.string "cantidad"
    t.string "serial"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "jugador"
    t.string "confirmation"
    t.string "usuarioventa"
  end

  create_table "reportetipoexcells", force: :cascade do |t|
    t.date "fecha"
    t.string "in"
    t.string "out"
    t.string "net"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "reportets", force: :cascade do |t|
    t.date "desde"
    t.date "hasta"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "rondaruletabbts", force: :cascade do |t|
    t.string "jugador"
    t.string "win"
    t.string "credit"
    t.string "jugadas"
    t.string "totalbet"
    t.string "winnernumberspin"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "rondaruletabts", force: :cascade do |t|
    t.string "jugador"
    t.string "win"
    t.string "credit"
    t.string "jugadas"
    t.string "totalbet"
    t.string "winnernumberspin"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "rondaruletats", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "rondats", force: :cascade do |t|
    t.string "jugador"
    t.string "credito"
    t.string "cartucho"
    t.string "posiciondisparo"
    t.string "resultado"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "singlepostransaccionests", force: :cascade do |t|
    t.string "creditin"
    t.string "cashout"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tipomaquinats", force: :cascade do |t|
    t.string "tipomaquina"
    t.string "descripcion"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "transaccionests", force: :cascade do |t|
    t.integer "maquinat_id"
    t.string "tipotransaccion"
    t.string "cantidad"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "comando"
    t.integer "jugador"
    t.string "serialmaquina"
    t.string "usuarioventa"
    t.index ["maquinat_id"], name: "index_transaccionests_on_maquinat_id"
  end

  create_table "usuariosbrts", force: :cascade do |t|
    t.string "nombre"
    t.string "apellido"
    t.string "usuario"
    t.string "contrasena"
    t.string "telefono"
    t.string "email"
    t.string "cedula"
    t.string "direccion"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "ledejaroncredit"
    t.string "loggedin"
    t.string "tipousuario"
    t.string "md5pc"
    t.string "consorcioasociado"
  end

end
