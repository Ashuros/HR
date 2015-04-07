package hr.dao;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.env.Environment;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.simple.SimpleJdbcCall;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;
import java.util.*;

@Repository
public class HumanResourcesDaoImpl implements HumanResourcesDao {

    private SimpleJdbcCall getAllTables;
    private SimpleJdbcCall saveDataToFile;
    private SimpleJdbcCall loadDataFromFile;
    private SimpleJdbcCall loadData;

    private final String PACKAGE_NAME = "PKG_PS_FJ_FILE";

    @Autowired
    public HumanResourcesDaoImpl(JdbcTemplate jdbcTemplate, Environment env) {
        getAllTables = new SimpleJdbcCall(jdbcTemplate).withFunctionName(env.getProperty("functions.getAllTables"));
        saveDataToFile = new SimpleJdbcCall(jdbcTemplate).withCatalogName(PACKAGE_NAME)
                .withProcedureName(env.getProperty("procedure.saveToFile"));
        loadDataFromFile = new SimpleJdbcCall(jdbcTemplate).withCatalogName(PACKAGE_NAME)
                .withFunctionName(env.getProperty("functions.loadDataFromFile"));
        loadData = new SimpleJdbcCall(jdbcTemplate).withCatalogName(PACKAGE_NAME)
                .withProcedureName(env.getProperty("procedure.loadData"));
    }

    @Override
    public List<String> getAllTableNames() {
        String tables = getAllTables.executeFunction(String.class);
        return Arrays.asList(tables.split(","));
    }

    @Override
    public void saveDataToFileByTableName(String tableName, String separator) {
        HashMap<String, Object> params = new HashMap<>();
        params.put("in_tableName", tableName);
        params.put("in_separator", separator);
        saveDataToFile.execute(params);
    }

    @Override
    public BigDecimal loadDataFromFile(String fileDirectory, String fileName, String separator) {
        HashMap<String, Object> params = new HashMap<>();
        params.put("in_fileDir", fileDirectory);
        params.put("in_fileName", fileName);
        params.put("in_separator", separator);
        return loadDataFromFile.executeFunction(BigDecimal.class, params);
    }

    @Override
    public BigDecimal loadData(String tableName, int commitOccurence) {
        HashMap<String, Object> params = new HashMap<>();
        params.put("in_tableName", tableName);
        params.put("in_commitOccurence", commitOccurence);
        return loadData.executeFunction(BigDecimal.class, params);
    }
}
