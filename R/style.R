arm_colors <- c("Good people" = "#4B4B4B", "Bad people" = "#007A87")

figure_theme <- function() {
  ggplot2::theme_minimal(base_size = 12, base_family = "sans") +
    ggplot2::theme(
      panel.grid.minor = ggplot2::element_blank(),
      panel.grid.major.y = ggplot2::element_blank(),
      plot.title = ggplot2::element_text(face = "bold", size = 15),
      plot.title.position = "plot",
      plot.caption = ggplot2::element_text(hjust = 0, size = 10),
      axis.title.y = ggplot2::element_blank(),
      text = ggplot2::element_text(color = "#222222"),
      legend.position = "none",
      plot.margin = ggplot2::margin(12, 16, 12, 12)
    )
}

save_figure <- function(plot, name, width = 7.4, height = 4.4) {
  ggplot2::ggsave(file.path("figs", paste0(name, ".pdf")), plot, width = width, height = height)
  ggplot2::ggsave(
    file.path("figs", paste0(name, ".png")), plot,
    width = width, height = height, dpi = 220, bg = "white"
  )
}
