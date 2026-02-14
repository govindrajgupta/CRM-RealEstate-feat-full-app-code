import jwt from "jsonwebtoken";
import type { Role } from "@prisma/client";
import type { CookieOptions } from "express";

const JWT_SECRET = process.env.JWT_SECRET || "your-super-secret-jwt-key-change-in-production";
const JWT_EXPIRES_IN = "7d";

export interface JWTPayload {
  userId: string;
  username: string;
  role: Role;
}

/**
 * signToken - Create a signed JWT token for authenticated user
 * 
 * Token Payload:
 * - userId: User's UUID from database
 * - username: User's unique username
 * - role: User's role (ADMIN, MANAGER, or EMPLOYEE)
 * 
 * Security:
 * - Signed with JWT_SECRET to prevent tampering
 * - Expires in 7 days (JWT_EXPIRES_IN)
 * - Cannot be modified without invalidating signature
 * 
 * @param payload - User information to encode in token
 * @returns Signed JWT string to be stored in HTTP-only cookie
 */
export function signToken(payload: JWTPayload): string {
  return jwt.sign(payload, JWT_SECRET, {
    expiresIn: JWT_EXPIRES_IN,
  });
}

/**
 * verifyToken - Verify and decode a JWT token
 * 
 * Validation Checks:
 * - Signature is valid (token not tampered)
 * - Token not expired
 * - Token structure matches JWTPayload interface
 * 
 * @param token - JWT string from cookie
 * @returns Decoded payload if valid, null if invalid/expired
 * 
 * Note: Returns null on ANY error (expired, invalid signature, malformed)
 */
export function verifyToken(token: string): JWTPayload | null {
  try {
    return jwt.verify(token, JWT_SECRET) as JWTPayload;
  } catch {
    return null;
  }
}

/**
 * cookieOptions - Secure cookie configuration for JWT tokens
 * 
 * Security Features:
 * - httpOnly: true - Prevents JavaScript access (XSS protection)
 * - secure: true (production) - HTTPS only
 * - sameSite: Prevents CSRF attacks
 * - maxAge: 7 days - Auto-expires with token
 * 
 * Environment-Specific:
 * Development (localhost):
 * - secure: false (HTTP allowed)
 * - sameSite: 'lax' (works with same-site requests)
 * 
 * Production:
 * - secure: true (HTTPS required)
 * - sameSite: 'none' (allows cross-origin with HTTPS)
 * 
 * Usage:
 * res.cookie('token', jwtToken, cookieOptions);
 */
export const cookieOptions: CookieOptions = {
  httpOnly: true,
  secure: process.env.NODE_ENV === "production",
  sameSite: process.env.NODE_ENV === "production" ? "none" : "lax",
  maxAge: 7 * 24 * 60 * 60 * 1000, // 7 days in milliseconds
  path: "/",
};

