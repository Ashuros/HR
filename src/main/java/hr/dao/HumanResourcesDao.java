package hr.dao;

import java.math.BigDecimal;
import java.util.List;

public interface HumanResourcesDao {

    public List<String> getAllTableNames();

    public void saveDataToFileByTableName(String tableName, String delimeter);

    public BigDecimal loadDataFromFile(String fileDirectory, String fileName, String delimeter);

    public BigDecimal loadData(String tableName, int commitOccurence);
}
