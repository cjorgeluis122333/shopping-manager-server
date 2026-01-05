package com.shopping.manager.service;

import com.shopping.manager.entity.Venta;
import com.shopping.manager.repository.VentaRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class ReporteService {

    @Autowired
    private VentaRepository ventaRepository;

    /**
     * Genera un reporte real de ventas para un rango de fechas
     */
    public List<Map<String, Object>> generarReporteReal(Long tiendaId, LocalDateTime startDate, LocalDateTime endDate) {
        List<Venta> ventas = ventaRepository.findByTiendaIdAndDateRange(tiendaId, startDate, endDate);
        return convertirVentasAReporte(ventas);
    }

    /**
     * Genera un reporte falso (inflado) basado en el reporte real
     * @param tiendaId ID de la tienda
     * @param startDate Fecha de inicio
     * @param endDate Fecha de fin
     * @param inflationPercent Porcentaje de inflación (0-200)
     */
    public List<Map<String, Object>> generarReporteFalso(Long tiendaId, LocalDateTime startDate, LocalDateTime endDate, double inflationPercent) {
        List<Map<String, Object>> reporteReal = generarReporteReal(tiendaId, startDate, endDate);
        
        // Validar porcentaje de inflación
        if (inflationPercent < 0 || inflationPercent > 200) {
            throw new IllegalArgumentException("El porcentaje de inflación debe estar entre 0 y 200");
        }

        // Aplicar inflación a cada venta
        List<Map<String, Object>> reporteFalso = new ArrayList<>();
        for (Map<String, Object> venta : reporteReal) {
            Map<String, Object> ventaInflada = new HashMap<>(venta);
            
            // Aplicar inflación al total
            Double totalOriginal = (Double) venta.get("total");
            Double multiplicador = 1 + (inflationPercent / 100.0);
            ventaInflada.put("total", totalOriginal * multiplicador);
            
            // Aplicar inflación a la cantidad (redondeado)
            Integer cantidadOriginal = (Integer) venta.get("cantidad");
            ventaInflada.put("cantidad", Math.round(cantidadOriginal * multiplicador));
            
            // Aplicar inflación al precio final
            Double precioOriginal = (Double) venta.get("precioFinal");
            ventaInflada.put("precioFinal", precioOriginal * multiplicador);
            
            // Marcar como reporte falso
            ventaInflada.put("esReporteFalso", true);
            ventaInflada.put("inflacionAplicada", inflationPercent);
            
            reporteFalso.add(ventaInflada);
        }

        return reporteFalso;
    }

    /**
     * Obtiene estadísticas resumidas del reporte
     */
    public Map<String, Object> obtenerEstadisticasReporte(List<Map<String, Object>> reporte) {
        Map<String, Object> estadisticas = new HashMap<>();

        if (reporte.isEmpty()) {
            estadisticas.put("totalVentas", 0);
            estadisticas.put("totalTransacciones", 0);
            estadisticas.put("promedio", 0);
            estadisticas.put("totalUnidades", 0);
            return estadisticas;
        }

        double totalVentas = 0;
        int totalUnidades = 0;
        int totalTransacciones = reporte.size();

        for (Map<String, Object> venta : reporte) {
            totalVentas += (Double) venta.get("total");
            totalUnidades += (Integer) venta.get("cantidad");
        }

        double promedio = totalVentas / totalTransacciones;

        estadisticas.put("totalVentas", totalVentas);
        estadisticas.put("totalTransacciones", totalTransacciones);
        estadisticas.put("promedio", promedio);
        estadisticas.put("totalUnidades", totalUnidades);

        return estadisticas;
    }

    /**
     * Convierte una lista de ventas a formato de reporte
     */
    private List<Map<String, Object>> convertirVentasAReporte(List<Venta> ventas) {
        List<Map<String, Object>> reporte = new ArrayList<>();

        for (Venta venta : ventas) {
            Map<String, Object> ventaMap = new HashMap<>();
            ventaMap.put("id", venta.getId());
            ventaMap.put("fecha", venta.getCreatAt());
            ventaMap.put("producto", venta.getProducto().getNombreProducto());
            ventaMap.put("cantidad", venta.getCantidad());
            ventaMap.put("precioFinal", venta.getPrecioFinal());
            ventaMap.put("total", venta.getTotalVenta());
            ventaMap.put("metodoPago", venta.getMetodoPago());
            ventaMap.put("empleado", venta.getEmpleado().getNombreCompleto());
            ventaMap.put("esReporteFalso", false);
            ventaMap.put("inflacionAplicada", 0);
            reporte.add(ventaMap);
        }

        return reporte;
    }
}
