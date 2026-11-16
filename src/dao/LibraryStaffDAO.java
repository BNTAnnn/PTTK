package dao;

import java.security.GeneralSecurityException;
import java.security.MessageDigest;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Base64;
import javax.crypto.SecretKeyFactory;
import javax.crypto.spec.PBEKeySpec;
import model.LibraryStaff1;

public class LibraryStaffDAO extends DAO {
    public LibraryStaff1 authenticate(String username, String password) {
        String sql = "SELECT m.id, m.username, m.password, m.fullName, s.libraryStaffCode, s.position "
                   + "FROM tblMember1 m JOIN tblLibraryStaff1 s ON s.id=m.id WHERE m.username=?";
        try (PreparedStatement statement = con.prepareStatement(sql)) {
            statement.setString(1, username);
            try (ResultSet result = statement.executeQuery()) {
                if (!result.next() || !matchesPassword(password, result.getString("password"))) return null;

                LibraryStaff1 staff = new LibraryStaff1();
                staff.setId(result.getInt("id"));
                staff.setUsername(result.getString("username"));
                staff.setFullName(result.getNString("fullName"));
                staff.setLibraryStaffCode(result.getString("libraryStaffCode"));
                staff.setPosition(result.getNString("position"));
                return staff;
            }
        } catch (SQLException e) {
            throw failure(e);
        }
    }

    private boolean matchesPassword(String password, String stored) {
        String[] parts = stored.split(":");
        if (parts.length != 3 || !"pbkdf2-sha256".equals(parts[0])) return false;
        byte[] salt;
        byte[] expected;
        try {
            salt = Base64.getDecoder().decode(parts[1]);
            expected = Base64.getDecoder().decode(parts[2]);
        } catch (IllegalArgumentException e) {
            return false;
        }
        if (salt.length < 16 || expected.length != 32) return false;

        PBEKeySpec spec = new PBEKeySpec(password.toCharArray(), salt, 600_000, 256);
        try {
            byte[] derived = SecretKeyFactory.getInstance("PBKDF2WithHmacSHA256").generateSecret(spec).getEncoded();
            return MessageDigest.isEqual(expected, derived);
        } catch (GeneralSecurityException e) {
            throw new IllegalStateException("Không thể xác thực tài khoản.", e);
        } finally {
            spec.clearPassword();
        }
    }
}
