package com.shopping.manager.controller;

import com.shopping.manager.dto.JwtResponse;
import com.shopping.manager.dto.LoginRequest;
import com.shopping.manager.entity.Empleado;
import com.shopping.manager.entity.Rol;
import com.shopping.manager.repository.EmpleadoRepository;
import com.shopping.manager.repository.TiendaRepository;
import com.shopping.manager.security.JwtUtils;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    @Autowired
    private AuthenticationManager authenticationManager;

    @Autowired
    private EmpleadoRepository empleadoRepository;

    @Autowired
    private TiendaRepository tiendaRepository;

    @Autowired
    private PasswordEncoder encoder;

    @Autowired
    private JwtUtils jwtUtils;

    @PostMapping("/login")
    public ResponseEntity<?> authenticateUser(@Valid @RequestBody LoginRequest loginRequest) {

        Authentication authentication = authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(loginRequest.getUsername(), loginRequest.getPassword()));

        SecurityContextHolder.getContext().setAuthentication(authentication);
        String jwt = jwtUtils.generateJwtToken(authentication);

        UserDetails userDetails = (UserDetails) authentication.getPrincipal();
        List<String> roles = userDetails.getAuthorities().stream()
                .map(GrantedAuthority::getAuthority)
                .collect(Collectors.toList());

        return ResponseEntity.ok(new JwtResponse(jwt, userDetails.getUsername(), roles));
    }

    @PostMapping("/register")
    public ResponseEntity<?> registerUser(@RequestBody Map<String, Object> request) {
        if (empleadoRepository.existsByUsername((String) request.get("username"))) {
            return ResponseEntity.badRequest().body("Error: Username is already taken!");
        }

        Empleado empleado = Empleado.builder()
                .username((String) request.get("username"))
                .password(encoder.encode((String) request.get("password")))
                .nombreCompleto((String) request.get("nombreCompleto"))
                .rol(Rol.valueOf((String) request.get("rol")))
                .tienda(tiendaRepository.findById(Long.valueOf(request.get("idTienda").toString())).orElseThrow())
                .activo(true)
                .build();

        empleadoRepository.save(empleado);
        return ResponseEntity.ok("User registered successfully!");
    }

    @PostMapping("/logout")
    public ResponseEntity<?> logoutUser() {
        SecurityContextHolder.clearContext();
        return ResponseEntity.ok("Log out successful!");
    }

    @PostMapping("/refresh-token")
    public ResponseEntity<?> refreshToken(@RequestBody Map<String, String> request) {
        String token = request.get("token");
        if (token != null && jwtUtils.validateJwtToken(token)) {
            String username = jwtUtils.getUserNameFromJwtToken(token);
            String newToken = jwtUtils.generateTokenFromUsername(username);
            return ResponseEntity.ok(Map.of("token", newToken));
        }
        return ResponseEntity.badRequest().body("Invalid token");
    }
}
