allprojects {
    repositories {
        google()
        mavenCentral()
    }
    // Fix for plugins that miss compileSdkVersion (e.g. google_sign_in_android 6.x)
    extra["compileSdkVersion"] = 34
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
