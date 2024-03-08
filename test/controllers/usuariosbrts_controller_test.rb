require 'test_helper'

class UsuariosbrtsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @usuariosbrt = usuariosbrts(:one)
  end

  test "should get index" do
    get usuariosbrts_url
    assert_response :success
  end

  test "should get new" do
    get new_usuariosbrt_url
    assert_response :success
  end

  test "should create usuariosbrt" do
    assert_difference('Usuariosbrt.count') do
      post usuariosbrts_url, params: { usuariosbrt: { apellido: @usuariosbrt.apellido, cedula: @usuariosbrt.cedula, contrasena: @usuariosbrt.contrasena, direccion: @usuariosbrt.direccion, email: @usuariosbrt.email, nombre: @usuariosbrt.nombre, telefono: @usuariosbrt.telefono, usuario: @usuariosbrt.usuario } }
    end

    assert_redirected_to usuariosbrt_url(Usuariosbrt.last)
  end

  test "should show usuariosbrt" do
    get usuariosbrt_url(@usuariosbrt)
    assert_response :success
  end

  test "should get edit" do
    get edit_usuariosbrt_url(@usuariosbrt)
    assert_response :success
  end

  test "should update usuariosbrt" do
    patch usuariosbrt_url(@usuariosbrt), params: { usuariosbrt: { apellido: @usuariosbrt.apellido, cedula: @usuariosbrt.cedula, contrasena: @usuariosbrt.contrasena, direccion: @usuariosbrt.direccion, email: @usuariosbrt.email, nombre: @usuariosbrt.nombre, telefono: @usuariosbrt.telefono, usuario: @usuariosbrt.usuario } }
    assert_redirected_to usuariosbrt_url(@usuariosbrt)
  end

  test "should destroy usuariosbrt" do
    assert_difference('Usuariosbrt.count', -1) do
      delete usuariosbrt_url(@usuariosbrt)
    end

    assert_redirected_to usuariosbrts_url
  end
end
