# This essentially "bootstraps" the library from a Ruby script
# The following code can easily be copied to the top of your
# new script to get you started.
#
# This code loads the JAR from the same directory the script file
# is located, then loads up a few commonly used classes from the
# JAR and then performs a few initialization tasks:
# - Make sure the Java look and feel is Windows in case were running via nuix_console.exe
#   this step makes sure the look is consistent regardless of where the script is ran
# - Pass an instance of the Utilities object to the library for its use
# - Pass the current Nuix version string to the library

script_directory = File.dirname(__FILE__)
require File.join(script_directory,"Nx.jar")
java_import "com.nuix.nx.NuixConnection"
java_import "com.nuix.nx.LookAndFeelHelper"
java_import "com.nuix.nx.dialogs.ChoiceDialog"
java_import "com.nuix.nx.dialogs.TabbedCustomDialog"
java_import "com.nuix.nx.dialogs.CommonDialogs"
java_import "com.nuix.nx.dialogs.ProgressDialog"
java_import "com.nuix.nx.dialogs.ProcessingStatusDialog"
java_import "com.nuix.nx.digest.DigestHelper"
java_import "com.nuix.nx.controls.models.Choice"

LookAndFeelHelper.setWindowsIfMetal
NuixConnection.setUtilities($utilities)
NuixConnection.setCurrentNuixVersion(NUIX_VERSION)

load File.join(script_directory,"CaseHistoryHelper.rb")
load File.join(script_directory,"AnnotationHistoryReportGenerator.rb")

time_stamp = org.joda.time.DateTime.new.toString("YYYY-MM-dd_HHss")

dialog = TabbedCustomDialog.new("Annotation History Review Report")
main_tab = dialog.addTab("main_tab","Main")
main_tab.appendDirectoryChooser("report_directory","Report Directory","C:\\")
main_tab.setText("report_directory","C:\\AnnotationHistoryReports\\#{time_stamp}")
main_tab.appendCheckBox("open_on_completion","Open Report Directory on Completion",true)

dialog.validateBeforeClosing do |values|
	if values["report_directory"].strip.empty?
		CommonDialogs.showWarning("Please provide a value for 'Report Directory'.")
		next false
	end
	next true
end

dialog.display
if dialog.getDialogResult == true
	values = dialog.toMap
	reporter = AnnotationHistoryReportGenerator.new(values["report_directory"])

	ProgressDialog.forBlock do |pd|
		pd.setTitle("Annotation History Review Report")
		pd.setAbortButtonVisible(false)
		pd.setSubProgressVisible(false)
		reporter.generate_report($current_case,pd)

		pd.setCompleted

		if values["open_on_completion"]
			java.awt.Desktop.getDesktop.open(java.io.File.new(values["report_directory"]));
		end
	end
end