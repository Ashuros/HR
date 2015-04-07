package hr.service;

import hr.dao.HumanResourcesDao;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.util.List;

@Service
public class HumanResourcesServiceImpl implements HumanResourcesService {

    @Autowired
    private HumanResourcesDao hrDao;

    @Override
    public List<String> getAllTableNames() {
        return hrDao.getAllTableNames();
    }

    @Override
    public void saveDataToFileByTableName(String tableName, String delimeter) {
        hrDao.saveDataToFileByTableName(tableName, delimeter);
    }

    @Override
    public BigDecimal loadDataFromFile(String fileDirectory, String fileName, String delimeter) {
        return hrDao.loadDataFromFile(fileDirectory, fileName, delimeter);
    }

    @Override
    public BigDecimal loadData(String tableName, int commitOccurence) {
        return hrDao.loadData(tableName, commitOccurence);
    }
}
