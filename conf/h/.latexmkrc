$pdflatex = 'pdflatex --shell-escape %O %S';
$pdf_previewer = "start evince";
$pdf_update_method = 0;

add_cus_dep('glo', 'gls', 0, 'run_makeglossaries');
add_cus_dep('acn', 'acr', 0, 'run_makeglossaries');

sub run_makeglossaries {
  if ( $silent ) {
    system "makeglossaries -q '$_[0]'";
  }
  else {
    system "makeglossaries '$_[0]'";
  };
}

push @generated_exts, 'glo', 'gls', 'glg';
push @generated_exts, 'acn', 'acr', 'alg';
$clean_ext .= ' %R.ist %R.xdy run.xml glsdefs loa lol %R.pdf %R-blx.bib';
$bibtex_use = 2;
$pdf_mode = 1;
$preview_continuous_mode = 1;