package hr.controller;

import hr.config.ApplicationConfig;
import hr.service.HumanResourcesService;
import javafx.beans.value.ChangeListener;
import javafx.beans.value.ObservableValue;
import javafx.collections.FXCollections;
import javafx.collections.ObservableList;
import javafx.event.ActionEvent;
import javafx.fxml.FXML;
import javafx.fxml.FXMLLoader;
import javafx.scene.Parent;
import javafx.scene.Scene;
import javafx.scene.control.Button;
import javafx.scene.control.ListView;
import javafx.stage.FileChooser;
import javafx.stage.Stage;
import org.springframework.context.ApplicationContext;
import org.springframework.context.annotation.AnnotationConfigApplicationContext;

import java.io.File;
import java.io.IOException;
import java.math.BigDecimal;

public class MainWindowController {

    private Stage stage;

    private Parent root;

    private FXMLLoader loader;

    private HumanResourcesService hrService;

    private String tableName;

    private BigDecimal numberOfRows;

    private File file;

    /* Buttons */
    @FXML
    private Button btnGetTables;

    @FXML
    private Button btnSaveToFile;

    @FXML
    private Button btnLoadBackupData;

    @FXML
    private Button btnGenerateData;

    /* List view */
    @FXML
    private ListView<String> listView;

    public MainWindowController() {
        ApplicationContext context = new AnnotationConfigApplicationContext(ApplicationConfig.class);
        this.hrService = context.getBean(HumanResourcesService.class);
    }

    public HumanResourcesService getHumanResourcesService() {
        return hrService;
    }

    public Stage getStage() {
        return stage;
    }

    public Parent getRoot() {
        return root;
    }

    public FXMLLoader getLoader() {
        return loader;
    }

    public HumanResourcesService getHrService() {
        return hrService;
    }

    public String getTableName() {
        return tableName;
    }

    public File getFile() {
        return file;
    }

    public void setNumberOfRows(BigDecimal inserted) {
        numberOfRows = inserted;
    }

    public BigDecimal getNumberOfRows() {
        return numberOfRows;
    }

    @FXML
    public void getAllTables(ActionEvent event) {
        if(event.getSource() == btnGetTables) {
            printTables();
        }
    }

    public void printTables() {
        ObservableList<String> data = FXCollections.observableArrayList(hrService.getAllTableNames());

        listView.setItems(data);

        listView.getSelectionModel().selectedItemProperty().addListener(new ChangeListener<String>() {
            @Override
            public void changed(ObservableValue<? extends String> observable, String oldValue, String newValue) {
                if (listView.getSelectionModel().getSelectedItem() != null) {
                    tableName = listView.getSelectionModel().getSelectedItem();
                    btnSaveToFile.setDisable(false);
                    btnGenerateData.setDisable(false);
                }
            }
        });
    }

    @FXML
    public void handleAction(ActionEvent event) throws IOException {
        if (event.getSource() == btnSaveToFile) {
            //get reference to the button's stage
            stage = (Stage) btnSaveToFile.getScene().getWindow();
            stage.setTitle("Save to file");
            //load up OTHER FXML document
            loader = new FXMLLoader(getClass().getResource("/fx/enterDelimeter.fxml"));
            root = (Parent) loader.load();
            DelimeterWindowController controller = loader.getController();
            controller.createController(this, "save");
        } else if (event.getSource() == btnLoadBackupData) {
            FileChooser fileChooser = new FileChooser();

            //Set extension filter
            FileChooser.ExtensionFilter extFilter = new FileChooser.ExtensionFilter("CSV", "*.csv");
            fileChooser.getExtensionFilters().add(extFilter);

            //Show open file dialog
            file = fileChooser.showOpenDialog(null);

            stage = (Stage) btnLoadBackupData.getScene().getWindow();
            stage.setTitle("Load backup data");
            loader = new FXMLLoader(getClass().getResource("/fx/enterDelimeter.fxml"));
            root = (Parent) loader.load();
            DelimeterWindowController controller = loader.getController();
            controller.createController(this, "load");
        } else if (event.getSource() == btnGenerateData) {
            stage = (Stage) btnGenerateData.getScene().getWindow();
            stage.setTitle("Generate data");
            loader = new FXMLLoader(getClass().getResource("/fx/enterCommitOccurence.fxml"));
            root = (Parent) loader.load();
            OccurenceWindowController controller = loader.getController();
            controller.createController(this, "generate");
        }
        //create a new scene with root and set the stage
        Scene scene = new Scene(root);
        stage.setScene(scene);
        stage.show();
    }
}
