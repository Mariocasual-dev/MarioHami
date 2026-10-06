using Microsoft.Data.SqlClient;
using RegistroEstudiantes.Modelos;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace RegistroEstudiantes.Datos
{
    public class CatalogoRepository
    {
        public List<OpcionCatalogo> ListarCarreras(int idArea)
        {
            const string sql = @"
        SELECT IdCarrera, Nombre
        FROM Carreras
        WHERE Activa = 1
          AND IdArea = @IdArea
        ORDER BY Nombre;";

            List<OpcionCatalogo> lista = new();

            using SqlConnection conexion = ConexionBD.CrearConexion();
            using SqlCommand comando = new(sql, conexion);

            comando.Parameters.AddWithValue("@IdArea", idArea);

            conexion.Open();

            using SqlDataReader lector = comando.ExecuteReader();

            while (lector.Read())
            {
                lista.Add(new OpcionCatalogo
                {
                    Id = lector.GetInt32(0),
                    Nombre = lector.GetString(1)
                });
            }

            return lista;
        }

        public List<OpcionCatalogo> ListarDepartamentos()
        {
            const string sql = @"
                SELECT IdDepartamento, Nombre
                FROM Departamentos
                ORDER BY Nombre;";

            List<OpcionCatalogo> lista = new();

            using SqlConnection conexion = ConexionBD.CrearConexion();
            using SqlCommand comando = new(sql, conexion);

            conexion.Open();

            using SqlDataReader lector = comando.ExecuteReader();

            while (lector.Read())
            {
                lista.Add(new OpcionCatalogo
                {
                    Id = lector.GetInt32(0),
                    Nombre = lector.GetString(1)
                });
            }

            return lista;
        }

        // VERSIÓN ASÍNCRONA PARA EL PASO 13
        public async Task<List<OpcionCatalogo>> ListarDepartamentosAsync(CancellationToken token = default)
        {
            const string sql = @"
                SELECT IdDepartamento, Nombre
                FROM Departamentos
                ORDER BY Nombre;";

            List<OpcionCatalogo> lista = new();

            using SqlConnection conexion = ConexionBD.CrearConexion();
            using SqlCommand comando = new(sql, conexion);

            await conexion.OpenAsync(token);

            using SqlDataReader lector = await comando.ExecuteReaderAsync(token);

            while (await lector.ReadAsync(token))
            {
                lista.Add(new OpcionCatalogo
                {
                    Id = lector.GetInt32(0),
                    Nombre = lector.GetString(1)
                });
            }

            return lista;
        }

        public List<OpcionCatalogo> ListarMunicipios(int idDepartamento)
        {
            const string sql = @"
                SELECT IdMunicipio, Nombre
                FROM Municipios
                WHERE IdDepartamento = @IdDepartamento
                ORDER BY Nombre;";

            List<OpcionCatalogo> lista = new();

            using SqlConnection conexion = ConexionBD.CrearConexion();
            using SqlCommand comando = new(sql, conexion);

            comando.Parameters.AddWithValue("@IdDepartamento", idDepartamento);

            conexion.Open();

            using SqlDataReader lector = comando.ExecuteReader();

            while (lector.Read())
            {
                lista.Add(new OpcionCatalogo
                {
                    Id = lector.GetInt32(0),
                    Nombre = lector.GetString(1)
                });
            }

            return lista;
        }

        public List<OpcionCatalogo> ListarAreas()
        {
            const string sql = @"
        SELECT IdArea, Nombre
        FROM AreasConocimiento
        ORDER BY Nombre;";

            List<OpcionCatalogo> lista = new();

            using SqlConnection conexion = ConexionBD.CrearConexion();
            using SqlCommand comando = new(sql, conexion);

            conexion.Open(); // <-- Faltaba esta línea en tu código original

            using SqlDataReader lector = comando.ExecuteReader();

            while (lector.Read())
            {
                lista.Add(new OpcionCatalogo
                {
                    Id = lector.GetInt32(0),
                    Nombre = lector.GetString(1)
                });
            }

            return lista;
        }

        // VERSIÓN ASÍNCRONA PARA EL PASO 13
        public async Task<List<OpcionCatalogo>> ListarAreasAsync(CancellationToken token = default)
        {
            const string sql = @"
        SELECT IdArea, Nombre
        FROM AreasConocimiento
        ORDER BY Nombre;";

            List<OpcionCatalogo> lista = new();

            using SqlConnection conexion = ConexionBD.CrearConexion();
            using SqlCommand comando = new(sql, conexion);

            await conexion.OpenAsync(token);

            using SqlDataReader lector = await comando.ExecuteReaderAsync(token);

            while (await lector.ReadAsync(token))
            {
                lista.Add(new OpcionCatalogo
                {
                    Id = lector.GetInt32(0),
                    Nombre = lector.GetString(1)
                });
            }

            return lista;
        }
        public async Task<List<OpcionCatalogo>> ListarCarrerasAsync(int idArea, CancellationToken token = default)
        {
            const string sql = @"
        SELECT IdCarrera, Nombre
        FROM Carreras
        WHERE Activa = 1
          AND IdArea = @IdArea
        ORDER BY Nombre;";

            List<OpcionCatalogo> lista = new();

            using SqlConnection conexion = ConexionBD.CrearConexion();
            using SqlCommand comando = new(sql, conexion);

            comando.Parameters.AddWithValue("@IdArea", idArea);

            await conexion.OpenAsync(token);

            using SqlDataReader lector = await comando.ExecuteReaderAsync(token);

            while (await lector.ReadAsync(token))
            {
                lista.Add(new OpcionCatalogo
                {
                    Id = lector.GetInt32(0),
                    Nombre = lector.GetString(1)
                });
            }

            return lista;
        }

        public async Task<List<OpcionCatalogo>> ListarMunicipiosAsync(int idDepartamento, CancellationToken token = default)
        {
            const string sql = @"
                SELECT IdMunicipio, Nombre
                FROM Municipios
                WHERE IdDepartamento = @IdDepartamento
                ORDER BY Nombre;";

            List<OpcionCatalogo> lista = new();

            using SqlConnection conexion = ConexionBD.CrearConexion();
            using SqlCommand comando = new(sql, conexion);

            comando.Parameters.AddWithValue("@IdDepartamento", idDepartamento);

            await conexion.OpenAsync(token);

            using SqlDataReader lector = await comando.ExecuteReaderAsync(token);

            while (await lector.ReadAsync(token))
            {
                lista.Add(new OpcionCatalogo
                {
                    Id = lector.GetInt32(0),
                    Nombre = lector.GetString(1)
                });
            }

            return lista;
        }

    }
}