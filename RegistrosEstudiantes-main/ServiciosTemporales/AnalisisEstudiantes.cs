using RegistroEstudiantes.Modelos;

namespace RegistroEstudiantes.ServiciosTemporales
{
    public static class AnalisisEstudiantes
    {
        // Paso 15: solo se consultan datos en memoria, sin controles ni conexiones SQL.
        public static Task<List<ResumenCarrera>> CrearResumenPorCarreraAsync(
            IReadOnlyList<Estudiante> estudiantes, CancellationToken token = default)
        {
            return Task.Run(() => estudiantes
                .AsParallel()
                .WithCancellation(token)
                .Where(e => e.Activo)
                .GroupBy(e => e.Carrera)
                .Select(grupo => new ResumenCarrera(
                    grupo.Key, grupo.Count(), grupo.Average(e => e.Promedio)))
                .OrderBy(resumen => resumen.Carrera)
                .ToList(), token);
        }

        // Paso 16: cada iteración escribe en un índice distinto del arreglo.
        public static Task<double[]> CalcularEnParaleloAsync(
            int cantidad = 200_000, CancellationToken token = default)
        {
            if (cantidad < 0)
                throw new ArgumentOutOfRangeException(nameof(cantidad));

            return Task.Run(() =>
            {
                double[] datos = Enumerable.Range(1, cantidad)
                    .Select(i => (double)i).ToArray();
                double[] resultados = new double[datos.Length];
                Parallel.For(0, datos.Length,
                    new ParallelOptions { CancellationToken = token }, i =>
                    {
                        resultados[i] = Math.Sqrt(datos[i]) * Math.Log(datos[i] + 1);
                    });
                return resultados;
            }, token);
        }
    }
}
