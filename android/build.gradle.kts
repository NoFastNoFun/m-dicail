import com.android.build.gradle.BaseExtension
import org.gradle.api.Project

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

fun Project.pinWorkingNdk() {
    extensions.findByType(BaseExtension::class.java)?.apply {
        // AGP forbids ndk.abiFilters when ABI splits are enabled (--split-per-abi).
        val splitPerAbi = findProperty("split-per-abi")?.toString()?.toBoolean() == true
        defaultConfig.ndk.abiFilters.clear()
        if (!splitPerAbi) {
            defaultConfig.ndk.abiFilters.add("arm64-v8a")
        }
        if (name == "whisper_kit") {
            ndkVersion = "27.0.12077973"
        }
    }
}

subprojects {
    if (state.executed) {
        pinWorkingNdk()
    } else {
        afterEvaluate { pinWorkingNdk() }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
