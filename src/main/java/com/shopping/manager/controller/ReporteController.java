package com.shopping.manager.controller;

import com.shopping.manager.service.ReporteService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/reportes")
@CrossOrigin(origins = "*", maxAge = 3600)
public class ReporteController {

    @Autowired
    private ReporteService reporteService;

    /**
     * Genera un reporte real de ventas
     */
    @GetMapping("/tienda/{tiendaId}/real")
    public ResponseEntity<Map<String, Object>> generarReporteReal(
            @PathVariable Long tiendaId,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime startDate,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime endDate) {
        
        try {
            List<Map<String, Object>> reporte = reporteService.generarReporteReal(tiendaId, startDate, endDate);
            Map<String, Object> estadisticas = reporteService.obtenerEstadisticasReporte(reporte);
            
            Map<String, Object> response = new HashMap<>();
            response.put("tiendaId", tiendaId);
            response.put("fechaInicio", startDate);
            response.put("fechaFin", endDate);
            response.put("tipo", "REAL");
            response.put("ventas", reporte);
            response.put("estadisticas", estadisticas);
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            return ResponseEntity.badRequest().build();
        }
    }

    /**
     * Genera un reporte falso (inflado) de ventas
     */
    @GetMapping("/tienda/{tiendaId}/falso")
    public ResponseEntity<Map<String, Object>> generarReporteFalso(
            @PathVariable Long tiendaId,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime startDate,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime endDate,
            @RequestParam(defaultValue = "10") double inflacionPorcentaje) {
        
        try {
            List<Map<String, Object>> reporte = reporteService.generarReporteFalso(tiendaId, startDate, endDate, inflacionPorcentaje);
            Map<String, Object> estadisticas = reporteService.obtenerEstadisticasReporte(reporte);
            
            Map<String, Object> response = new HashMap<>();
            response.put("tiendaId", tiendaId);
            response.put("fechaInicio", startDate);
            response.put("fechaFin", endDate);
            response.put("tipo", "FALSO");
            response.put("inflacionAplicada", inflacionPorcentaje);
            response.put("ventas", reporte);
            response.put("estadisticas", estadisticas);
            
            return ResponseEntity.ok(response);
        } catch (IllegalArgumentException e) {
            Map<String, Object> error = new HashMap<>();
            error.put("error", e.getMessage());
            return ResponseEntity.badRequest().body(error);
        } catch (Exception e) {
            return ResponseEntity.badRequest().build();
        }
    }
}
